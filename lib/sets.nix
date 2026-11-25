# The set loader.
#
# A set is a named, switchable group of packages and settings living under
# modules/. Its position in the tree is its name: modules/dev/python.nix is the
# set `dev.python`, switched on with `modules.dev.python.enable = true`.
#
# A set file takes one of two forms:
#
#   * data, an attribute set
#
#       {
#         description = "Python toolchain";
#         packages = [ "python313" { git = [ "basic" "user" ]; } ];
#         sets = [ "dev.git" ];           # other sets this one switches on
#         config = { ... };               # plain NixOS configuration
#         default = false;                # on unless a profile turns it off
#       }
#
#     from which the enable option and the conditional wiring are generated.
#     Being plain data, `yo` can read and edit these files.
#
#   * a function, which is an ordinary NixOS module for sets that need their
#     own options or logic.
{ lib, ... }:

let
  inherit (builtins) attrNames concatStringsSep filter isAttrs isFunction map toString;
  inherit (lib) getAttrFromPath mkDefault mkIf mkMerge mkOption optional setAttrByPath splitString types;

  tree = import ./tree.nix;
  inherit (tree) normalisePackages;

  schema = [ "description" "packages" "sets" "config" "default" ];

  # Build the NixOS module for a data set.
  fromData = path: file: data:
    let
      name = concatStringsSep "." path;
      unknown = filter (key: !(builtins.elem key schema)) (attrNames data);
      checked =
        if unknown != [ ]
        then throw "${toString file}: unknown keys in set `${name}`: ${concatStringsSep ", " unknown} (expected ${concatStringsSep ", " schema})"
        else data;
    in
      { config, ... }: {
        _file = toString file;
        key = toString file;

        options.modules = setAttrByPath path {
          enable = mkOption {
            type = types.bool;
            default = checked.default or false;
            example = true;
            description = "Whether to enable ${checked.description or "the ${name} set"}.";
          };
        };

        config = mkIf (getAttrFromPath path config.modules).enable (mkMerge (
          [ { modules.singleton = normalisePackages (checked.packages or [ ]); } ]
          # A default, so that a profile can still switch a member off.
          ++ map (set: { modules = setAttrByPath (splitString "." set ++ [ "enable" ]) (mkDefault true); }) (checked.sets or [ ])
          ++ optional (checked ? config) checked.config
        ));
      };

  # Every set under `modulesDir`, as a list of NixOS modules.
  setModules = modulesDir:
    map (set:
      let
        content = import set.file;
      in
        if isFunction content then set.file
        else if isAttrs content then fromData set.path set.file content
        else throw "${toString set.file}: a set must be an attribute set (data) or a function (module)"
    ) (tree.sets modulesDir);

in {
  inherit normalisePackages setModules;
}
