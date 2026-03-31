{ config, pkgs, inputs, lib, options, ... }:

let
  inherit (lib) mkOption filterAttrs mapAttrs mapAttrsToList flatten hasSuffix;
  inherit (lib.types) attrsOf listOf str;
  inherit (lib.mine) mkOpt;

  # Scan a directory of package directories, returning { <pkg> = [ <entry> ... ]; }
  # Only includes directories at the top level (each package is a directory),
  # and only .nix files or subdirectories within each package.
  getDir = dir:
    let
      topLevel = filterAttrs (_: type: type == "directory") (builtins.readDir dir);
    in
      mapAttrs (pkg: _:
        let
          entries = builtins.readDir "${dir}/${pkg}";
          validEntries = filterAttrs
            (name: type: type == "directory" || hasSuffix ".nix" name)
            entries;
        in
          builtins.attrNames validEntries
      ) topLevel;

  # Flatten package entries into a list of importable paths.
  importList = dir:
    flatten (mapAttrsToList
      (name: entries: map (x: ../src/${name}/${x}) entries)
      (getDir dir));

in {
  options.modules = {
    singleton = mkOpt (attrsOf (listOf str)) {};
    empty = mkOpt (attrsOf (listOf str)) {};
  };

  imports = importList ../src;
}
