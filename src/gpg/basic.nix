{ config, lib, pkgs, inputs, ... }:

{
  home.programs.gpg = {
    enable = true;
  };
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}
