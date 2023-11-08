{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "sddm" "corners"
{
  services.xserver.displayManager.sddm = {
    
    theme = "corners"; # You can also choose sugar-dark
    settings = {
      Theme.CursorTheme = "breeze_cursors";
    };
  };

  environment.systemPackages =
    let
      themes =
        pkgs.libsForQt5.callPackage ./sddm-themes.nix {};
    in
      [ themes.sddm-theme-corners ]; # Change to sddm-sugar-dark if using sugar-dark
}
