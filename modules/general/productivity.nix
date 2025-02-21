{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.general.productivity;
  inherit (lib.mine) mkEnableOpt mkOpt';
in {
  options.modules.general.productivity = {
    enable = mkEnableOpt "Whether to enable productivity toolchains";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      # awscli2 = [ "basic" ];
      dropbox = [ "basic" ];
      calibre = [ "basic" ];
      zathura = [ "basic" ];
      thunderbird = [ "basic" ];
      # remarkable2-toolchain = [ "basic" ];
      newsflash = [ "basic" ];
      imagemagick = [ "basic" ];
      dolphin = [ "basic" ];
      chromium = [ "basic" ];
      lf = [ "basic" ];
      krusader = [ "basic" ];
      libreoffice = [ "basic" ];
      nyxt = [ "basic" ];
      zoom-us = [ "basic" ] ++ (if config.modules.desktop.wayland.enable then [ "wayland" ] else []);
      unicode-paracode = [ "basic" ];
      dict = [ "basic" ];
      rsync = [ "basic" ];
      anki = [ "basic" ];
      ddgr = [ "basic" ];
      cloudflared = [ "basic" ];
      zotero = [ "basic" ];
      wechat-uos = [ "basic" ];
      chatgpt = [ "basic" ];
      # goldendict-ng = [ "basic" ];
    };
  };
}
