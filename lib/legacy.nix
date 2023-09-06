{ lib,  ... }:

with lib;
with builtins;
let
  useSystemModules = modulesList:
    map (x: ../. + ("/modules/" + x)) modulesList;

  useHomeModules = modulesList:
    map (x: ../. + ("/modules/" + x + "/home.nix")) modulesList;

  transparentify = colour:
    "#00${substring 1 (stringLength colour - 1) colour}";

in {
  inherit useSystemModules useHomeModules flattenTree;
}
