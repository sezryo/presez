{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.shell.tools;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.shell.tools = {
    enable = mkEnableOpt "Whether to enable useful command line tools bundles, lots are rewriiten CLI by Rust";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      pueue = [ "basic" ];
      grex = [ "basic" ];
      lsd = [ "basic" ];
      ripgrep = [ "basic" ];
      bottom = [ "basic" ];
      du-dust = [ "basic" ];
      procs = [ "basic" ];
      tealdeer = [ "basic" ];
      bat = [ "basic" ];
      sd = [ "basic" ];
      fd = [ "basic" ];
      htop = [ "basic" ];
      gojq = [ "basic" ];
      jaq = [ "basic" ];
      cbonsai = [ "basic" ];
      zip = [ "basic" ];
      unzip = [ "basic" ];
      psmisc = [ "basic" ];
      tokei = [ "basic" ];
    };
  };
}
