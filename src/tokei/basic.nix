{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "tokei" "basic"

{
  home.packages = [ pkgs.tokei ];
}
