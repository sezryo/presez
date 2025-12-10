{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "dust" "basic"

{
  home.packages = [ pkgs.dust ];
}
