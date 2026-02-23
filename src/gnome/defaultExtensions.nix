{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "gnome" "defaultExtensions"
  
{ 
  home = {
    packages = with pkgs.gnomeExtensions; [
      blur-my-shell
      unite
      auto-accent-colour
      disable-3-finger-gestures-redux
      kimpanel
      just-another-search-bar
      just-perfection
      open-bar
      paperwm # Install this manually and change patches.js until gnome 49 problem fixed.
      search-light
      vertical-workspaces
    ];
    
    dconf.settings."org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions; [
        blur-my-shell.extensionUuid
        unite.extensionUuid
        auto-accent-colour.extensionUuid
        disable-3-finger-gestures-redux.extensionUuid
        kimpanel.extensionUuid
        just-another-search-bar.extensionUuid
        just-perfection.extensionUuid
        open-bar.extensionUuid
        paperwm.extensionUuid
        search-light.extensionUuid
	vertical-workspaces.extensionUuid
      ];
    };
  };
}
