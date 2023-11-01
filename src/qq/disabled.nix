{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "qq" "disabled"

{
  runtime.control.qq.disabled = lib.mkDefault true;
}
