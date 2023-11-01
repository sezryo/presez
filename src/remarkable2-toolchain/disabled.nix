{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "remarkable2-toolchain" "disabled"

{
  runtime.control.remarkable2-toolchain.disabled = lib.mkDefault true;
}
