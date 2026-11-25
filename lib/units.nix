{ lib, ... }:

let
  inherit (lib) mkIf mkMerge;

  mkIfElse = p: yes: no: mkMerge [
    (mkIf p yes)
    (mkIf (!p) no)
  ];

in {
  inherit mkIfElse;
}
