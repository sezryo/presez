{ config, pkgs, lib, ... }:

lib.mine.mkIfProfile config.modules "cloudflared" "basic"

{
  home.packages = [ pkgs.cloudflared ];
}
