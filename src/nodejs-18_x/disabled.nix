{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "nodejs-18_x" "disabled"

{
  runtime.control.nodejs-18_x.disabled = lib.mkDefault true;
}
