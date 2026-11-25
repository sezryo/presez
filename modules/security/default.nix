{ pkgs, config, lib, inputs, ... }:

{
  security.sudo.wheelNeedsPassword = lib.mkDefault false;
}
