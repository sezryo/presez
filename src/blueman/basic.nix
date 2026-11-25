{ config, lib, pkgs, inputs, ... }:

{
  services.blueman = {
    enable = true;
  };
}
