{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "spice" "vdagentd"

{
  services.spice-vdagentd.enable = true;
}
