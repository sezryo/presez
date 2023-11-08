{ lib, ... }:

with lib;
with builtins;
let
  mkIfElse = p: yes: no: mkMerge [
    (mkIf p yes)
    (mkIf (!p) no)
  ];

  mkIfProfile = base: src: component: drv:
    mkIf (hasAttrByPath [ "${src}" ] base.singleton)
      (mkIf (elem component base.singleton."${src}")
        (mkIf ((! hasAttrByPath [ "${src} "] base.empty) || (! elem component base.empty."${src}")) drv));
  
in {
  inherit mkIfElse mkIfProfile;
}
