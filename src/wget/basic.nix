{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "wget" "basic"

{
  environment.systemPackages = [ pkgs.wget ];
}
