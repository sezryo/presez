{ config, lib, pkgs, inputs, ... }:

let
  core-py = ps: with ps; [
    numpy
    matplotlib
    scipy
    mock
    sympy
    pandas
    jupyter
    keras
    tensorflow
    arch
    toolz
    seaborn
    pytest
    returns
  ];
in lib.mine.mkIfProfile config.modules "python313" "basic" {
  home.packages = [
    (pkgs.python313.withPackages core-py)
  ];
}
