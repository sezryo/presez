{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.virt-manager pkgs.virt-viewer ];
}
