{ lib, ... }:

with lib;
with builtins;
let
  mkIfElse = p: yes: no: mkMerge [
    (mkIf p yes)
    (mkIf (!p) no)
  ];

  mkIfProfile = base: src: component: drv:
    mkIf (hasAttrByPath [ "${src}" ] base)
      (mkIf (elem component base."${src}")
        (mkIf (! elem "disabled" base."${src}") drv));
  
in {
  inherit mkIfElse mkIfProfile;
}
