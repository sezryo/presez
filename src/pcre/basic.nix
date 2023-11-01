{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "pcre" "basic"

{
  environment.systemPackages = [ pkgs.pcre ];
}
