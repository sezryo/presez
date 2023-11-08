{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "firefox" "defaultSettings"

{ 
  home.programs.firefox = {
    profiles."main.profile" = {
      id = 0;
      isDefault = true;

      search = {
        default = "DuckDuckGo";
        force = true;
        order = [ "DuckDuckGo" "Google" ];
      };

      settings = {
        "browser.startup.page" = 3; # Always resume the previous browser session.
        "browser.startup.homepage" = "https://getpocket.com/saves?src=navbar";
        "browser.search.isUS" = false;
        "distribution.searchplugins.defaultLocale" = "en-GB";
        "general.useragent.locale" = "en-GB";
        "browser.bookmarks.showMobileBookmarks" = true;

        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "layers.acceleration.force-enabled" = true;
        "gfx.webrender.all" = true;
        "svg.context-properties.content.enabled" = true;

        "font.cjk_pref_fallback_order" = "ja,zh-tw,zh-hk,zh-cn,ko";
        "devtools.editor.keymap" = "emacs";
        "ui.key.accelKey" = 18;
        "ui.key.chromeAccess" = 6;
      };
    };
  };
}
