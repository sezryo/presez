{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.discord-ptb ]; # The unstable version of discord; use discord-canary for the nightly version
}
