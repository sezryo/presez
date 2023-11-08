{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "burpsuite" "basic"

{
  home.packages = [ pkgs.burpsuite ];
}
