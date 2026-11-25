# The file system is the namespace: this file is the only place that knows how
# the repository is laid out. It depends on nothing but `builtins`, so the
# NixOS loaders and the catalogue read by `yo` always agree on what exists.
let
  inherit (builtins)
    attrNames concatMap filter listToAttrs pathExists readDir stringLength substring;

  hasSuffix = suffix: s:
    let
      n = stringLength s;
      m = stringLength suffix;
    in
      n >= m && substring (n - m) m s == suffix;

  removeSuffix = suffix: s:
    if hasSuffix suffix s
    then substring 0 (stringLength s - stringLength suffix) s
    else s;

  # Directory entries as [ { name; type; path; } ], sorted by name.
  ls = dir:
    let
      entries = readDir dir;
    in
      map (name: {
        inherit name;
        type = entries.${name};
        path = dir + "/${name}";
      }) (attrNames entries);

  isDir = entry: entry.type == "directory";

  # The notation sets and profiles use to name packages: a bare name selects
  # the `basic` variant, an attribute set names variants explicitly.
  #
  #   [ "bat" { git = [ "basic" "user" ]; } ]
  #     -> { bat = [ "basic" ]; git = [ "basic" "user" ]; }
  normalisePackages = entries:
    builtins.zipAttrsWith (_: builtins.concatLists)
      (map (entry: if builtins.isString entry then { ${entry} = [ "basic" ]; } else entry) entries);
  isNix = entry: entry.type == "regular" && hasSuffix ".nix" entry.name;

  # src/<package>/<variant>.nix
  # src/<package>/<variant>/default.nix   (a variant that ships its own files)
  # src/<package>/meta.nix                (optional description, updaters, ...)
  #
  # Returns { <package> = { dir; meta; variants = [ { name; file; } ]; }; }.
  packages = srcDir:
    let
      variantsOf = dir:
        concatMap (entry:
          if isNix entry && entry.name != "meta.nix" then
            [ { name = removeSuffix ".nix" entry.name; file = entry.path; } ]
          else if isDir entry && pathExists (entry.path + "/default.nix") then
            [ { inherit (entry) name; file = entry.path + "/default.nix"; } ]
          else
            [ ]
        ) (ls dir);
    in
      listToAttrs (map (entry: {
        inherit (entry) name;
        value = {
          dir = entry.path;
          meta =
            if pathExists (entry.path + "/meta.nix")
            then import (entry.path + "/meta.nix")
            else { };
          variants = variantsOf entry.path;
        };
      }) (filter isDir (ls srcDir)));

  # modules/<category>/<name>.nix declares `modules.<category>.<name>`; a
  # default.nix speaks for its directory. Every .nix file under the tree is a
  # set, so nothing has to be listed by hand.
  #
  # Returns [ { path = [ "<category>" "<name>" ]; file; } ] in directory order.
  sets = modulesDir:
    let
      walk = prefix: dir:
        concatMap (entry:
          if isDir entry then
            walk (prefix ++ [ entry.name ]) entry.path
          else if isNix entry then
            [ {
              path = if entry.name == "default.nix" then prefix else prefix ++ [ (removeSuffix ".nix" entry.name) ];
              file = entry.path;
            } ]
          else
            [ ]
        ) (ls dir);
    in
      walk [ ] modulesDir;

  # Every .nix file directly inside `dir`, as a list of paths.
  modulesIn = dir: map (entry: entry.path) (filter isNix (ls dir));

  # profiles/<user>/*.nix                  modules shared by the user's machines
  # profiles/<user>/profile.nix            the user's selection of sets (data)
  # profiles/<user>/<machine>/*.nix        modules for one machine
  # profiles/<user>/<machine>/profile.nix  what that machine adds or changes (data)
  #
  # Returns { <user> = { dir; modules; data; machines = { <machine> = { dir; modules; data; }; }; }; }
  # where `data` is the path of profile.nix, or null.
  profiles = profilesDir:
    let
      describe = dir: {
        inherit dir;
        modules = filter (path: baseNameOf path != "profile.nix") (modulesIn dir);
        data = if pathExists (dir + "/profile.nix") then dir + "/profile.nix" else null;
      };
      named = entries: f: listToAttrs (map (entry: { inherit (entry) name; value = f entry; }) entries);
    in
      named (filter isDir (ls profilesDir)) (user:
        describe user.path // {
          machines = named (filter isDir (ls user.path)) (machine: describe machine.path);
        });

in {
  inherit normalisePackages packages sets modulesIn profiles;
}
