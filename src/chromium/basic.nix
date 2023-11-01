{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "chromium" "basic"

{
  home.packages = [ pkgs.chromium ];
  environment.systemPackages = [ pkgs.chromium ];
}
