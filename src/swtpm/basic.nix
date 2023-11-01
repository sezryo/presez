{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "swtpm" "basic"

{
  environment.systemPackages = [ pkgs.swtpm ];
}
