{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "tokei" "basic"

{
  home.packages = [ pkgs.tokei ];
}
