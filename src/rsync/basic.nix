{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "rsync" "basic"

{
  services.rsyncd.enable = true;
}
