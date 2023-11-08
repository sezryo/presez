{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "clojure" "basic"

{
  home.packages = [ pkgs.clojure ];
}
