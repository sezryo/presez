{ lib, ... }:

let
  inherit (lib) mkOption types;

  # On/off switches. The description is used as written (mkEnableOption would
  # put "Whether to enable" in front of it).
  mkEnableOptIf = description: default:
    mkOption {
      inherit description default;
      type = types.bool;
      example = true;
    };
in {
  inherit mkEnableOptIf;
  mkEnableOpt = description: mkEnableOptIf description false;
  mkEnableOpt' = description: mkEnableOptIf description true;

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
