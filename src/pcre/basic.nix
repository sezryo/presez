{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "pcre" "basic"

{
  environment.systemPackages = [ pkgs.pcre ];
}
