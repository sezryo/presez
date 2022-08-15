{ config, pkgs, lib, ... }:

{
  services.xserver.displayManager.lightdm.greeters.mini = {
    enable = true;
    user = "your-username";
    extraConfig = ''
      [greeter]
      show-password-label = false
      [greeter-theme]
      background-image = ""
    '';
  };
}
