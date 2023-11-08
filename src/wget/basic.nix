{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "wget" "basic"

{
  environment.systemPackages = [ pkgs.wget ];
}
