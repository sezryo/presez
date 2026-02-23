{ config, lib, pkgs, inputs, ... }:

let
  vcv-rack-fixed = pkgs.stdenv.mkDerivation rec {
    pname = "vcv-rack-fixed";
    version = "2.6.6";

    src = pkgs.fetchzip {
      url = "https://vcvrack.com/downloads/RackFree-${version}-lin-x64.zip";
      sha256 = "WRxv8RQ/z0dqwMijdWG/HABx9lTLBAhNPtpr06dIS4c=";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      # 1. Create a directory for the app
      mkdir -p $out/opt/vcv-rack
      cp -r * $out/opt/vcv-rack

      # 2. Create the executable binary
      mkdir -p $out/bin

      # We create a script that:
      # a) Enters the directory (Crucial for fonts to load!)
      # b) Runs the app using steam-run (Crucial for graphics/libraries!)
      cat > $out/bin/Rack <<EOF
      #!${pkgs.bash}/bin/bash
      cd $out/opt/vcv-rack
      exec ${pkgs.steam-run}/bin/steam-run ./Rack "\$@"
      EOF

      chmod +x $out/bin/Rack

      # 3. (Optional) Create a Desktop Item so it appears in your launcher
      mkdir -p $out/share/applications
      cat > $out/share/applications/vcv-rack.desktop <<EOF
      [Desktop Entry]
      Name=VCV Rack Free
      Exec=$out/bin/Rack
      Icon=$out/opt/vcv-rack/res/icon.png
      Type=Application
      Categories=Audio;AudioVideo;
      EOF
    '';
  };

in lib.mine.mkIfProfile config.modules "vcv-rack" "basic"

{
  home.packages = [ vcv-rack-fixed ];
}
