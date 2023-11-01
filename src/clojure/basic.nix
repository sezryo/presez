{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "clojure" "basic"

{
  home.packages = [ pkgs.clojure ];
}
