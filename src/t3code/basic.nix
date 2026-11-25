{ config, lib, pkgs, inputs, ... }:

let
  # Pinned release metadata; refreshed by `yo update t3code` (see meta.nix).
  release = builtins.fromJSON (builtins.readFile ./release.json);
  inherit (release) version;
  assets = release.systems.${pkgs.stdenv.hostPlatform.system};

  desktopSrc = pkgs.fetchurl assets.desktop;
  desktopContents = pkgs.appimageTools.extract {
    pname = "t3code-desktop";
    inherit version;
    src = desktopSrc;
  };

  desktop = pkgs.appimageTools.wrapType2 {
    pname = "t3code-desktop";
    inherit version;
    src = desktopSrc;
    extraInstallCommands = ''
      install -Dm444 ${desktopContents}/t3code.desktop \
        "$out/share/applications/t3code.desktop"
      substituteInPlace "$out/share/applications/t3code.desktop" \
        --replace-fail 'Exec=AppRun' 'Exec=t3code-desktop'
      cp -r ${desktopContents}/usr/share/icons "$out/share/"
    '';
  };

  cliContents = pkgs.runCommand "t3code-cli-${version}-extracted" {
    nativeBuildInputs = [ pkgs.gnutar pkgs.gzip ];
  } ''
    mkdir -p "$out"
    tar -xzf ${pkgs.fetchurl assets.cli} -C "$out" --strip-components=1
  '';

  # Keep upstream's matching runtime and native helpers together, unmodified.
  cli = pkgs.buildFHSEnv (pkgs.appimageTools.defaultFhsEnvArgs // {
    pname = "t3";
    inherit version;
    runScript = "${cliContents}/t3";
  });

  unwrapped = pkgs.symlinkJoin {
    pname = "t3code-unwrapped";
    inherit version;
    paths = [ desktop cli ];
    meta = pkgs.t3code.meta // {
      changelog = "https://github.com/pingdotgg/t3code/releases/tag/v${version}";
      platforms = builtins.attrNames release.systems;
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    };
  };

  t3code = pkgs.t3code.override {
    t3code-unwrapped = unwrapped;
    # The official release already includes the matching resource monitor.
    enableResourceMonitor = false;
  };
in

{
  # Return to the normal package once nixpkgs catches up with this release.
  home.packages = [
    (if lib.versionAtLeast pkgs.t3code.version version then pkgs.t3code else t3code)
  ];
}
