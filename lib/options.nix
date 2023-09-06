{ lib, ... }:

let
  inherit (lib) mkEnableOption mkOption types;
in {
  
  mkEnableOpt = x: (mkEnableOption x);
  mkEnableOpt' = x: (mkEnableOption x) // {default = true;};

  mkOpt = type: default:
    mkOption {inherit type default;};
  mkOpt' = type: default: description:
    mkOption {inherit type default description;};

  mkOptStr = value:
    mkOption {
      type = with types; uniq str;
      default = value;
    };

  mkBoolOpt = default:
    mkOption {
      inherit default;
      type = types.bool;
      example = true;
    };
}
