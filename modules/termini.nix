{ config, pkgs, inputs, lib, options, ... }:

with lib;
with builtins;
with lib.types;
let
  inherit (lib.mine) mkOpt mkOpt' mkEnableOpt mkEnableOpt';
  getDir = dir: mapAttrs
    (file: type:
      mapAttrsToList (name: value: "${name}") (readDir "${dir}/${file}")
    )
    (readDir dir);

  importList = dir: flatten (mapAttrsToList
    (name: value:
      map (x: ../src/${name}/${x}) value
    )
    (getDir dir));
  
in {
  options = {
    modules = {
      singleton = mkOpt (attrsOf (listOf str)) {};
      empty = mkOpt (attrsOf (listOf str)) {};
    };
  };
  imports = importList ../src;
}
