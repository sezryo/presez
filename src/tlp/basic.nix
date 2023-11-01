{ config, lib, pkgs, inputs, ... }:

with lib;

lib.mine.mkIfProfile config.modules.singleton "tlp" "basic"

{
  services.tlp.enable = mkDefault ((versionOlder (versions.majorMinor version) "21.05")
                                       || !config.services.power-profiles-daemon.enable);
}
