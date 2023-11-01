{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "bash" "disabled"

{
  runtime.control.bash.disabled = lib.mkDefault true;
}
