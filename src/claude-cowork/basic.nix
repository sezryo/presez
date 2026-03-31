{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "claude-cowork" "basic"

{
  services.claude-cowork.enable = true;
}
