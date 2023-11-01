{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gnuplot" "disabled"

{
  runtime.control.gnuplot.disabled = lib.mkDefault true;
}
