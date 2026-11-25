{ config, lib, pkgs, inputs, ... }:

{
  home.packages = [ pkgs.discord-ptb ]; # The unstable version of discord; use discord-canary for the nightly version
}
