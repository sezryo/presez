{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    gcc cmake
  ];
}
