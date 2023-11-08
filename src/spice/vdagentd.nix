{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "spice" "vdagentd"

{
  services.spice-vdagentd.enable = true;
}
