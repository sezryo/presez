{ pkgs, lib, ... }:

{
  services.swayidle = {
    enable = true;
    package = pkgs.swayidle;
    events = [
      { event = "before-sleep"; command = "${pkgs.swaylock-effects}/bin/swaylock"; }
    ];
    systemdTarget = "hyprland-session.target";
    # extraArgs = [ "-w" ] # -w flag is already passed in the default settings
  };
  home.packages = [ pkgs.swayidle ];
}
