# Profiles and hosts.
#
# A host is a (user, machine) pair found under profiles/. It is built from, in
# this order:
#
#   1. the sets, the packages and the always-on core,
#   2. the user's modules, then the machine's modules,
#   3. the user's profile.nix, as defaults, and
#   4. the machine's profile.nix, which adds to or overrides the user's.
#
# A profile.nix is data:
#
#   {
#     modules = { ... };     # values for the options under `modules.*`
#     packages = [ ... ];    # extra packages, in the notation sets use
#     exclude = [ ... ];     # packages to leave out although a set selects them
#   }
{ lib, ... }:

let
  inherit (builtins) attrNames concatMap filter listToAttrs toString;
  inherit (lib) mapAttrsRecursive mkMerge mkOverride optional;
  inherit (lib.mine) normalisePackages packagesModule setModules;

  tree = import ./tree.nix;

  schema = [ "modules" "packages" "exclude" ];

  # Stronger than an option's own default and than `mkDefault`, weaker than a
  # plain definition: what the user's shared profile is applied with.
  userPriority = 900;

  # Turn a profile.nix into a NixOS module. With a `priority`, every value
  # under `modules` is applied at that priority.
  profileModule = { file, priority ? null }:
    let
      data = import file;
      unknown = filter (key: !(builtins.elem key schema)) (attrNames data);
      checked =
        if unknown != [ ]
        then throw "${toString file}: unknown keys ${builtins.concatStringsSep ", " unknown} (expected ${builtins.concatStringsSep ", " schema})"
        else data;
      prioritise =
        if priority == null
        then (values: values)
        else mapAttrsRecursive (_: mkOverride priority);
    in {
      _file = toString file;
      key = toString file;
      config.modules = mkMerge [
        (prioritise (checked.modules or { }))
        {
          singleton = normalisePackages (checked.packages or [ ]);
          empty = normalisePackages (checked.exclude or [ ]);
        }
      ];
    };

  # Build every host under `root`/profiles as { "<user>-<machine>" = <nixosSystem>; }.
  # `modules` are extra modules for all hosts, typically those of flake inputs.
  mkHosts = { self, inputs, root, modules ? [ ], system ? "x86_64-linux" }:
    let
      base = modules ++ [
        { imports = setModules (root + "/modules"); }
        (packagesModule (root + "/src"))
        { imports = tree.modulesIn (root + "/core"); }
      ];

      users = tree.profiles (root + "/profiles");

      mkHost = userName: machineName:
        let
          user = users.${userName};
          machine = user.machines.${machineName};
        in
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules =
            base
            ++ [ { yo.profile = { user = userName; machine = machineName; }; } ]
            ++ user.modules
            ++ machine.modules
            ++ optional (user.data != null) (profileModule { file = user.data; priority = userPriority; })
            ++ optional (machine.data != null) (profileModule { file = machine.data; });
          specialArgs = { inherit self inputs lib; };
        };
    in
      listToAttrs (concatMap (userName:
        map (machineName: {
          name = "${userName}-${machineName}";
          value = mkHost userName machineName;
        }) (attrNames users.${userName}.machines)
      ) (attrNames users));

in {
  inherit profileModule mkHosts;
}
