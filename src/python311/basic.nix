{ config, lib, pkgs, inputs, ... }:

let
  core-py = ps: with ps; [
    numpy
    matplotlib
    scipy
    mock
    sympy
  ];
in lib.mine.mkIfProfile config.modules "python311" "basic" {
  home.packages = [
    (pkgs.python311.withPackages core-py)
  ];
}
