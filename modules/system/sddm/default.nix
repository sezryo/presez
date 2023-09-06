{ pkgs, lib,  ... }:

{
  services.xserver.displayManager.sddm = {
    enable = true;
    enableHidpi = true;
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
