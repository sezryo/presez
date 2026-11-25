# The catalogue: everything the repository contains, as plain data.
#
# This is what `yo` reads. It needs neither nixpkgs nor the flake, so it
# evaluates in a few milliseconds:
#
#   nix-instantiate --eval --strict --json --arg root ./. lib/catalog.nix
{ root }:

let
  inherit (builtins)
    attrNames concatStringsSep isAttrs isFunction listToAttrs map mapAttrs stringLength substring toString;

  tree = import ./tree.nix;

  rootString = toString root;

  # A path inside the repository, relative to its root, as a string.
  relative = path:
    substring (stringLength rootString + 1) (-1) (toString path);

  packages = mapAttrs (_: package: {
    inherit (package) meta;
    variants = map (variant: {
      inherit (variant) name;
      file = relative variant.file;
    }) package.variants;
  }) (tree.packages (root + "/src"));

  sets = listToAttrs (map (set:
    let
      content = import set.file;
      data = isAttrs content;
    in {
      name = concatStringsSep "." set.path;
      value = { file = relative set.file; }
        // (if data then {
          kind = "data";
          description = content.description or "";
          default = content.default or false;
          packages = tree.normalisePackages (content.packages or [ ]);
          sets = content.sets or [ ];
          config = content ? config;
        } else {
          kind = if isFunction content then "module" else "invalid";
        });
    }) (tree.sets (root + "/modules")));

  describeProfile = profile: {
    dir = relative profile.dir;
    modules = map relative profile.modules;
    data =
      if profile.data == null then null
      else {
        file = relative profile.data;
        value =
          let content = import profile.data;
          in {
            modules = content.modules or { };
            packages = tree.normalisePackages (content.packages or [ ]);
            exclude = tree.normalisePackages (content.exclude or [ ]);
          };
      };
  };

  profiles = mapAttrs (_: user:
    describeProfile user // {
      machines = mapAttrs (_: describeProfile) user.machines;
    }) (tree.profiles (root + "/profiles"));

in {
  root = rootString;
  inherit packages sets profiles;
}
