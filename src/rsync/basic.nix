{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "rsync" "basic"

{
  services.rsyncd.enable = true;
}
