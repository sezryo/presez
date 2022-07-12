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

  environment.systemPackages = with pkgs; [
    taffybar dmenu nitrogen alacritty rofi polybar
  ];
}
