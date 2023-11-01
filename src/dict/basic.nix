{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "dict" "basic"

{
  services.dictd.enable = true;
}
