{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "electron" "wayland"
  
{
  home.configFile."electron26-flags.conf".source = ./electron-flags.conf;
  home.configFile."electron25-flags.conf".source = ./electron-flags.conf;
  home.configFile."electron24-flags.conf".source = ./electron-flags.conf;
  home.configFile."electron23-flags.conf".source = ./electron-flags.conf;
  home.configFile."electron22-flags.conf".source = ./electron-flags.conf;
  home.configFile."electron21-flags.conf".source = ./electron-flags.conf;
  home.configFile."electron20-flags.conf".source = ./electron-flags.conf;
  home.configFile."electron19-flags.conf".source = ./electron-flags.conf;
  home.configFile."electron18-flags.conf".source = ./electron-flags.conf;
}
