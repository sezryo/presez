{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "graphviz" "disabled"

{
  runtime.control.graphviz.disabled = lib.mkDefault true;
}
