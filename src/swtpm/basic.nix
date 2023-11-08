{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "swtpm" "basic"

{
  environment.systemPackages = [ pkgs.swtpm ];
}
