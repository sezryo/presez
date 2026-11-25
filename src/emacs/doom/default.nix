{ config, lib, pkgs, inputs, ... }:

let
  myEmacs = pkgs.emacs-pgtk;
  doomSyncInputs = pkgs.writeText "doom-sync-inputs" ''
    ${myEmacs}
    ${./config.el}
    ${./init.el}
    ${./packages.el}
  '';

in rec {
  environment.systemPackages = [ myEmacs ];
  home = {
    services.emacs = {
      package = myEmacs;
      client.enable = true;
      defaultEditor = true;
    };
    programs.emacs = {
      package = myEmacs;
    };
    activation.installDoomEmacs = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -d "${config.user.configDir}/emacs" ]; then
        rm -rf ${config.user.homeDir}/.emacs.d
        echo "Previous emacs configuration disabled."
        ${pkgs.git}/bin/git clone --depth=1 --single-branch "https://github.com/doomemacs/doomemacs" "${config.user.configDir}/emacs"
        echo "Doom Emacs downloaded. Please run 'doom install' in your terminal."
      fi
    '';
    # Rebuild Doom's generated init files for this Emacs before services reload.
    # Keep daemon restarts independent of package management and preserve sessions.
    activation.syncDoomEmacs = lib.hm.dag.entryBetween
      [ "reloadSystemd" ] [ "installDoomEmacs" "linkGeneration" ] ''
      doomSyncStamp="${config.user.stateDir}/doom/nix-sync-inputs"
      if ! cmp -s ${doomSyncInputs} "$doomSyncStamp"; then
        doomPreviousEmacs=""
        if [ -r "$doomSyncStamp" ]; then
          read -r doomPreviousEmacs < "$doomSyncStamp" || true
        fi
        doomRebuildArgs=()
        if [ "$doomPreviousEmacs" != "${myEmacs}" ]; then
          doomRebuildArgs=(--rebuild)
        fi

        run env \
          EMACS="${myEmacs}/bin/emacs" \
          EMACSDIR="${config.user.configDir}/emacs" \
          DOOMDIR="${config.user.configDir}/doom" \
          PATH="${myEmacs}/bin:${pkgs.git}/bin:${config.user.homeDir}/.nix-profile/bin:/etc/profiles/per-user/${config.user.name}/bin:/run/current-system/sw/bin:$PATH" \
          ${pkgs.runtimeShell} "${config.user.configDir}/emacs/bin/doom" \
          --force sync -U -e "''${doomRebuildArgs[@]}"

        # A failed sync leaves the previous stamp intact so activation retries it.
        run install -Dm600 ${doomSyncInputs} "$doomSyncStamp"
      fi
    '';
    configFile."doom/config.el".source = ./config.el;
    configFile."doom/init.el".source = ./init.el;
    configFile."doom/packages.el".source = ./packages.el;

  };
  environment.sessionVariables = rec {
    # To enable doom as bin utility
    PATH = [ "${config.user.configDir}/emacs/bin" ];
  };
}
  
