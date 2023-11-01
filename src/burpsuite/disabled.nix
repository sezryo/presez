{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "burpsuite" "disabled"

{
  runtime.control.burpsuite.disabled = lib.mkDefault true;
}
