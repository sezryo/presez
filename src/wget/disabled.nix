{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "wget" "disabled"

{
  runtime.control.wget.disabled = lib.mkDefault true;
}
