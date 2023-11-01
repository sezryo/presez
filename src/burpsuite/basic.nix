{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "burpsuite" "basic"

{
  home.packages = [ pkgs.burpsuite ];
}
