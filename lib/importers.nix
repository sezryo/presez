# Inspired by https://github.com/bangedorrunt/nix/blob/tdt/lib/importers.nix
{ lib, ... }:
let
  flattenTree =
    tree: let
      op = sum: path: val: let
        pathStr = builtins.concatStringsSep "." path; # dot-based reverse DNS notation
      in
        if builtins.isPath val
        then
          # builtins.trace "${toString val} is a path"
          (sum
            // {
              "${pathStr}" = val;
            })
        else if builtins.isAttrs val
        then
          # builtins.trace "${builtins.toJSON val} is an attrset"
          # recurse into that attribute set
          (recurse sum path val)
        else
          # ignore that value
          # builtins.trace "${toString path} is something else"
          sum;

      recurse = sum: path: val:
        builtins.foldl'
        (sum: key: op sum (path ++ [key]) val.${key})
        sum
        (builtins.attrNames val);
    in
      recurse {} [] tree;

  rakeLeaves =
    dirPath: let
      seive = file: type:
      # Only rake `.nix` files or directories
        (type == "regular" && lib.hasSuffix ".nix" file) || (type == "directory");

      collect = file: type: {
        name = lib.removeSuffix ".nix" file;
        value = let
          path = dirPath + "/${file}";
        in
          if
            (type == "regular")
            || (type == "directory" && builtins.pathExists (path + "/default.nix"))
          then path
          # recurse on directories that don't contain a `default.nix`
          else rakeLeaves path;
      };

      files = lib.filterAttrs seive (builtins.readDir dirPath);
    in
      lib.filterAttrs (n: v: v != {}) (lib.mapAttrs' collect files);
in {
  inherit rakeLeaves flattenTree;
}
