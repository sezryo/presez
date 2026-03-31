{ config, lib, pkgs, inputs, ... }:

let
  flags = ./electron-flags.conf;
  versions = lib.genList (i: toString (i + 18)) 30; # electron 18 through 47
in
lib.mine.mkIfProfile config.modules "electron" "wayland"

{
  home.configFile = lib.listToAttrs (map (v: {
    name = "electron${v}-flags.conf";
    value = { source = flags; };
  }) versions);
}
