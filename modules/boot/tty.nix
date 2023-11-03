{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;

let
  cfg = config.modules.boot.tty;
  inherit (lib.mine) mkEnableOpt' mkOpt';
  themes = [ "catppuccin" ];
in {
  options.modules.boot.tty = {
    enable = mkEnableOpt' "Whether to enable tty management";
    theme = mkOpt' (enum themes) null "Whhich theme to use for tty, currently only for grub";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      console = {
        enable = true;
        earlySetup = true;
        keyMap = "us";
        packages = with pkgs; [ terminus_font ];
        font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
      };
    }
    (mkIf (cfg.theme == "catppuccin") {
      boot.loader.grub.extraConfig = ''
        GRUB_CMDLINE_LINUX="vt.default_red=48,231,166,229,140,244,129,181,98,231,166,229,140,244,129,165 vt.default_grn=52,130,209,200,170,184,200,191,104,130,209,200,170,184,200,173 vt.default_blu=70,132,137,144,238,228,190,226,128,132,137,144,238,228,190,206"
      ''; 
    })
  ]);
}
