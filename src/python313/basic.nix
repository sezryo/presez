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
    # arch
    toolz
    seaborn
    pytest
    returns
  ];
in {
  home.packages = [
    (pkgs.python313.withPackages core-py)
  ];
}
