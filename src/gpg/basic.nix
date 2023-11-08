{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "gpg" "basic"

{
  home.programs.gpg = {
    enable = true;
  };
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}
