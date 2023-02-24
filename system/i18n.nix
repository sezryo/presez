{ pkgs, lib, ... }:
{
  time.timeZone = "Europe/London";
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings.LC_TIME = "de_DE.UTF-8"; 
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-rime
        fcitx5-chinese-addons
        fcitx5-table-extra
      ];
      fcitx5.enableRimeData = true;
    };
  };

   fonts = {
    enableDefaultFonts = true;
    fontDir.enable = true;
    fonts = with pkgs; [
      noto-fonts
      jost
      noto-fonts-emoji
      fira-code
      fira-code-symbols
      noto-fonts-cjk
      hanazono
      source-han-sans source-han-serif source-han-mono
      sarasa-gothic
      arphic-ukai arphic-uming
      unfonts-core
      # nerdfonts
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
      times-newer-roman
      material-symbols
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
