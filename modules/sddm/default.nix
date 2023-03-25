{ pkgs, lib,  ... }:

{
  services.xserver.displayManager.sddm = {
    enable = true;
    enableHidpi = true;
    theme = "corners"; # You can also choose sugar-dark
  };

  environment.systemPackages =
    let
      themes =
        pkgs.libsForQt5.callPackage ./sddm-themes.nix {};
    in
      [ themes.sddm-theme-corners ]; # Change to sddm-sugar-dark if using sugar-dark

}
