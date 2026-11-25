{ config, lib, pkgs, inputs, ... }:

{
  home.services.pueue = {
    enable = true;
  };
}
