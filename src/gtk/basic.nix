{ config, lib, pkgs, inputs, ... }:

{
  home.gtk = {
    enable = true;
  };
  home.packages = [ pkgs.gtk4 ];
  home.activation.removeGtkBackup = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      run rm -f ${config.user.configDir}/gtk-4.0/gtk.css.backup
  '';
}
