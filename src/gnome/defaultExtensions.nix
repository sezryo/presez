{ config, lib, pkgs, inputs, ... }:

let
  # GNOME Shell 51 changed APIs that some of the extensions below still rely on, and
  # extensions.gnome.org has no fixed releases for them yet. The ports defined here were
  # verified against that shell version only. They shadow the `pkgs.gnomeExtensions`
  # attributes of the same name in the lists at the bottom of this file.
  portedShell = "51";

  # What extensions.gnome.org already ships for the installed GNOME Shell.
  shellReady = pkgs."gnome${lib.versions.major pkgs.gnome-shell.version}Extensions" or { };

  # Lists `portedShell` in the extension's metadata, which is a no-op once upstream does.
  declarePorted = extension: extension.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.jq ];
    postInstall = (old.postInstall or "") + ''
      metadata="$out/share/gnome-shell/extensions/${extension.extensionUuid}/metadata.json"
      jq --arg shell ${portedShell} '."shell-version" |= (. + [$shell] | unique)' "$metadata" > metadata.ported
      cp metadata.ported "$metadata"
    '';
  });

  # Unite 85 runs unmodified on GNOME Shell 51 (hardpixel/unite-shell#428).
  unite = declarePorted pkgs.gnomeExtensions.unite;

  # Text entries no longer emit `key-press-event` for Enter in GNOME Shell 51, so the
  # query is also submitted from the entry's `activate` signal.
  just-another-search-bar = declarePorted (
    pkgs.gnomeExtensions.just-another-search-bar.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        if ! grep -q "'activate'" extension.js; then
          substituteInPlace extension.js --replace-fail \
            "entry.connect('key-press-event', this._onSearchKeyPress.bind(this));" \
            "entry.connect('key-press-event', this._onSearchKeyPress.bind(this)); entry.connect('activate', this._onSearchIcoClick.bind(this));"
        fi
      '';
    })
  );

  # PaperWM supports GNOME Shell 51 since v51.0.0, but extensions.gnome.org has not
  # accepted that release yet (paperwm/PaperWM#1212). Falls back to the packaged
  # extension as soon as nixpkgs has one for the installed shell.
  paperwm = shellReady."paperwm@paperwm.github.com" or (
    pkgs.gnomeExtensions.paperwm.overrideAttrs (_: rec {
      version = "51.0.0";
      src = pkgs.fetchFromGitHub {
        owner = "paperwm";
        repo = "PaperWM";
        tag = "v${version}";
        hash = "sha256-m01roFOC/iGHWlKer6X/Qn+MWDl6NJ1YG0KPz3IiqH4=";
      };
    })
  );

  # Spotlight is not yet packaged in the pinned nixpkgs.
  extensionUuid = "spotlight@nin";
  spotlight = pkgs.stdenvNoCC.mkDerivation {
    pname = "gnome-shell-extension-spotlight";
    version = "2026.15";

    src = pkgs.fetchFromGitHub {
      owner = "itsnin";
      repo = "spotlight";
      rev = "d67c9aa141d612b55a156e04073e67518660330c";
      hash = "sha256-sRowrxMwdcduhdJbXgvPzSBei7QCnXEaWWEvU4GwvJA=";
    };

    nativeBuildInputs = [ pkgs.glib ];

    # GNOME Shell 51 removed the `vertical` property of St widgets (itsnin/spotlight#35).
    postPatch = ''
      substituteInPlace lib/popup/widget/spotlightPopup.js \
        --replace-fail "vertical: true," "orientation: Clutter.Orientation.VERTICAL,"
    '';

    buildPhase = ''
      runHook preBuild
      glib-compile-schemas --strict schemas
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      extensionDir="$out/share/gnome-shell/extensions/${extensionUuid}"
      mkdir -p "$extensionDir"
      cp -r extension.js metadata.json prefs.js stylesheet.css lib prefs schemas "$extensionDir/"
      runHook postInstall
    '';

    passthru = { inherit extensionUuid; };

    meta = {
      description = "Spotlight-inspired launcher for GNOME Shell";
      homepage = "https://github.com/itsnin/spotlight";
      license = lib.licenses.gpl3Plus;
      platforms = lib.platforms.linux;
    };
  };
in

{ 
  home = {
    packages = with pkgs.gnomeExtensions; [
      blur-my-shell
      unite
      kimpanel
      just-another-search-bar
      just-perfection
      paperwm
      spotlight
    ];
    
    dconf.settings."org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions; [
        blur-my-shell.extensionUuid
        unite.extensionUuid
        kimpanel.extensionUuid
        just-another-search-bar.extensionUuid
        just-perfection.extensionUuid
        paperwm.extensionUuid
        spotlight.extensionUuid
      ];
    };
  };
}
