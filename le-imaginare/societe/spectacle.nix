{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    exportConfiguration = true;
    /*
    displayManager.lightdm.enable = true;
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages: [
         # haskellPackages.taffybar
         haskellPackages.List
         haskellPackages.monad-logger
         haskellPackages.xmonad
       ];
    };
    */
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    layout = "us";
    libinput.enable = true;
  };

  environment.systemPackages = with pkgs; [
    taffybar dmenu nitrogen alacritty
  ];
}
