{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "dict" "basic"

{
  services.dictd.enable = true;
}
