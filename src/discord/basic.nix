{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "discord" "basic"

{
  home.packages = [ pkgs.discord-ptb ]; # The unstable version of discord; use discord-canary for the nightly version
}
