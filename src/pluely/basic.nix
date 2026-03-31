{ config, lib, pkgs, inputs, ... }:

let
  pname = "pluely";
  version = "0.1.9";

  src = pkgs.fetchurl {
    url = "https://github.com/iamsrikanthnani/pluely/releases/download/app-v${version}/Pluely_${version}_amd64.AppImage";
    hash = "sha256-lULs74QaaPdlOosMmJRmWgI9bryuIc/ZbHLPNEf8ATw=";
  };

  extracted = pkgs.appimageTools.extractType2 { inherit pname version src; };

  pluely = pkgs.buildFHSEnv {
    name = pname;
    targetPkgs = pkgs: with pkgs; [
      # Core C/C++ runtime
      stdenv.cc.cc.lib
      zlib
      expat

      # GTK / WebKit
      webkitgtk_4_1
      gtk3
      glib
      glib-networking
      cairo
      pango
      gdk-pixbuf
      librsvg
      fontconfig
      freetype
      fribidi
      harfbuzz
      at-spi2-atk
      at-spi2-core
      dbus
      gsettings-desktop-schemas
      enchant
      libgcrypt
      libgpg-error
      libthai
      libdatrie
      libepoxy
      libtasn1
      p11-kit

      # Audio
      libpulseaudio
      alsa-lib

      # Network / TLS
      openssl
      libsoup_3
      nss
      nspr

      # Graphics / EGL
      mesa
      mesa.drivers
      libGL
      libdrm
      libgbm
      vulkan-loader

      # X11 / Wayland
      xorg.libX11
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXrandr
      xorg.libxcb
      wayland
      libxkbcommon

      # GStreamer (media)
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good

      # Kerberos (libcom_err) — krb5 ships .so.3 but Ubuntu-built binary needs .so.2
      krb5
      (pkgs.runCommand "libcom_err-compat" {} ''
        mkdir -p $out/lib
        ln -s ${pkgs.krb5.lib}/lib/libcom_err.so.3 $out/lib/libcom_err.so.2
      '')
    ];
    runScript = "${extracted}/usr/bin/pluely --no-sandbox";
    profile = ''
      export LIBGL_DRIVERS_PATH="${pkgs.mesa.drivers}/lib/dri"
      export __EGL_VENDOR_LIBRARY_FILENAMES="${pkgs.mesa.drivers}/share/glvnd/egl_vendor.d/50_mesa.json"
    '';
  };
in
lib.mine.mkIfProfile config.modules "pluely" "basic"
{
  home.packages = [ pluely ];

  home.desktopEntries.pluely = {
    name = "Pluely";
    comment = "Open Source AI Assistant";
    exec = "${pluely}/bin/pluely";
    terminal = false;
    categories = [ "Utility" "Office" ];
  };
}
