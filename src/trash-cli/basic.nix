{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "trash-cli" "basic"

{
  home.packages = [ pkgs.trash-cli ];
}
