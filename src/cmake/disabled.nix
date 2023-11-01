{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "cmake" "disabled"

{
  runtime.control.cmake.disabled = lib.mkDefault true;
}
