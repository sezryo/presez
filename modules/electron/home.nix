{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.electron_22 ];
  home.file.".config/electron-flags.conf".source = ./electron-flags.conf;
  # home.file.".config/electron21-flags.conf".source = ./electron-flags.conf;
}
