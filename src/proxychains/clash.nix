{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "proxychains" "clash"

{
  programs.proxychains = {
    enable = lib.mkDefault false;
    proxies."clash" = {
      enable = true;
      type = "http";
      host = "127.0.0.1";
      port = 7890;
    };
  };
}
