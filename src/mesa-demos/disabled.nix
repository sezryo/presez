{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "mesa-demos" "disabled"

{
  runtime.control.mesa-demos.disabled = lib.mkDefault true;
}
