{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "firefox" "simplefox"
{
  # This CSS style cridits to github.com/migueravila/SimpleFox
  home.file."firefox" = {
    source = ./chrome;
    target = ".mozilla/firefox/main.profile/chrome";
    recursive = true;
  };
}
