{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "psc-package" "disabled"

{
  runtime.control.psc-package.disabled = lib.mkDefault true;
}
