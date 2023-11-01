{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "clojure" "disabled"

{
  runtime.control.clojure.disabled = lib.mkDefault true;
}
