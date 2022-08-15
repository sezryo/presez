{ pkgs, config, lib, ... }:

{
  services.xserver.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    config = ./myMonad.hs;
    extraPackages = haskellPackages: [
      haskellPackages.List
      haskellPackages.monad-logger
      haskellPackages.xmonad
      haskellPackages.dbus
    ];
  };
}
