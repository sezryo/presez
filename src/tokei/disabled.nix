{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "tokei" "disabled"

{
  runtime.control.tokei.disabled = lib.mkDefault true;
}
