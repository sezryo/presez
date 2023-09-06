{ config, lib, pkgs, inputs, ... }:

{
  environment = {
    sessionVariables = rec {
      XDG_CACHE_HOME  = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME   = "$HOME/.local/share";
      XDG_STATE_HOME  = "$HOME/.local/state";
    };
    etc = {
      home-manager.source = "${inputs.home-manager}";
      nixpkgs.source = "${inputs.nixpkgs}";
      latest.source = "${inputs.latest}";
    };
    # List of acceptable shells in /etc/shells
    shells = with pkgs; [ bash xonsh nushell ];
  };
}
