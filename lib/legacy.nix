{ lib, ... }:

let
  inherit (builtins) substring stringLength;

  transparentify = colour:
    "#00${substring 1 (stringLength colour - 1) colour}";

in {
  inherit transparentify;
}
