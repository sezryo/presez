{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.locale;
  inherit (lib.mine) mkEnableOpt;
in {
  imports = [
    ./china.nix
    ./japan.nix
    ./uk.nix
  ];
  options.modules.locale = {
    enable = mkEnableOpt "Whether to enable locale setting modules";
    defaultFonts = mkEnableOpt "Enable this to install default font packages";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      fonts = {
        enableDefaultPackages = true;
        fontDir.enable = true;
      };
    }
    (mkIf cfg.defaultFonts {
      fonts = {
        packages = with pkgs; [
          unifont unifont_upper
          jetbrains-mono
          jost
          noto-fonts noto-fonts-emoji noto-fonts-cjk-sans
          fira-code fira-code-symbols
          hanazono
          source-han-sans source-han-serif source-han-mono
          sarasa-gothic
          arphic-ukai arphic-uming
          unfonts-core
          # nerd-fonts
          nerd-fonts.fira-code
          material-symbols
        ];
        fontconfig = {
          defaultFonts = {
            serif = [ "Source Han Serif SC" ];
            sansSerif = [ "Source Han Sans SC" ];
            monospace = [ "jetbrains-mono" ];
            emoji = [ "Noto Emoji" ];
          };
        };
      };
    })
  ]);
}
