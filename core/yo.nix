{ config, lib, options, pkgs, ... }:

# yo, the helper that manages this configuration, and what it needs to know
# about the system it is running on.
let
  inherit (lib) mkOption types;
  inherit (lib.mine) optionsOf selectionOf;

  cfg = config.yo;
in {
  options.yo = {
    profile = {
      user = mkOption {
        type = types.str;
        description = "The user directory under profiles/ this system is built from.";
      };
      machine = mkOption {
        type = types.str;
        description = "The machine directory under the user's profile this system is built from.";
      };
      name = mkOption {
        type = types.str;
        default = "${cfg.profile.user}-${cfg.profile.machine}";
        description = "The name of this system's flake output.";
      };
    };

    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ../yo { };
      defaultText = "pkgs.callPackage ../yo { }";
      description = "The yo package to install.";
    };

    state = mkOption {
      type = types.attrs;
      internal = true;
      readOnly = true;
      description = "What this configuration says about itself, published as /etc/yo/state.json.";
    };
  };

  config = {
    yo.state = {
      inherit (cfg) profile;
      root = toString config.dotfiles.dir;
      packages = selectionOf config.modules;
      options = optionsOf { options = options.modules; config = config.modules; root = ../.; };
    };

    environment.systemPackages = [ cfg.package ];
    environment.etc."yo/state.json".text = builtins.toJSON cfg.state;
  };
}
