{ config, pkgs, ... }:
{
  xsession = {
    enable = true;
    scriptPath = ".hm-xsession";
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages: with haskellPackages; [
        taffybar
        List
        monad-logger
        xmonad
        dbus
      ];
      config = pkgs.writeText "xmonad.hs" ''
        ${builtins.readFile ./config.hs}
      '';
    };
  };
}
