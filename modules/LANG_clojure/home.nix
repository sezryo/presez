{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [ clojure ];
}
