{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gh" "disabled"

{
  runtime.control.gh.disabled = lib.mkDefault true;
}
