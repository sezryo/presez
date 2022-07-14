{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    exportConfiguration = true;
    displayManager.lightdm.greeters.mini = {
      enable = true;
      user = "your-username";
      extraConfig = ''
        [greeter]
        show-password-label = false
        [greeter-theme]
        background-image = ""
      '';
    };
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages: [
         # haskellPackages.taffybar
         haskellPackages.List
         haskellPackages.monad-logger
         haskellPackages.xmonad
       ];
      config = ./strongMonad.hs;
    };
    layout = "us";
    libinput.enable = true;
  };

  programs.nm-applet.enable = true;
  service.blueman.enable = true;
  service.dbus.enable = true;
  systemd.services.upower.enable = true;
  services.picom = {
    enable = true;
    activeOpacity = "1.0";
    inactiveOpacity = "0.8";
    backend = "glx";
    fade = true;
    fadeDelta = 5;
    opacityRule = [ "100:name *= 'i3lock'" ];
    shadow = true;
    shadowOpacity = "0.75";
  };

  environment.systemPackages = with pkgs; [
    taffybar dmenu nitrogen alacritty rofi polybar
  ];
}
