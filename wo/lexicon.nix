{ pkgs, lib, ... }:
{
  time.timeZone = "Asia/Shanghai";
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings.LC_TIME = "de_DE.UTF-8"; 
    inputMethod = {
      enabled = "ibus";
      ibus.engines = with pkgs.ibus-engines; [
        rime
      ];
    };
  };

   fonts = {
    enableDefaultFonts = true;
    fontDir.enable = true;
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-emoji
      fira-code
      fira-code-symbols
      noto-fonts-cjk
      hanazono
      source-han-sans source-han-serif source-han-mono
      sarasa-gothic
      arphic-ukai arphic-uming
      unfonts-core
      nerdfonts
      times-newer-roman
    ];
    fontconfig = {
      defaultFonts = {
        serif = [ "Source Han Serif SC" ];
        sansSerif = [ "Source Han Sans SC" ];
        monospace = [ "Sarasa Mono SC" ];
        emoji = [ "Noto Emoji" ];
      };
    };
  };

}
