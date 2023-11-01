{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "krusader" "disabled"

{
  runtime.control.krusader.disabled = lib.mkDefault true;
}
