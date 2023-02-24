{ config, lib, pkgs, ... }:

{
  environment.variables = rec {
    QT_QPA_PLATFORM = "wayland";
  };
}
