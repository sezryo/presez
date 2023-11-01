{ config, lib, pkgs
, stdenv
, fetchFromGitHub
, qtbase
, wrapQtAppsHook
, qtquickcontrols2
, qtgraphicaleffects
, qtsvg
, qtdeclarative
, sddm-kcm
, ... }:

{
  sddm-theme-corners = stdenv.mkDerivation rec {
    pname = "sddm-theme-corners";
    version = "4f87e57";
    dontBuild = true;
    buildInputs = [ qtbase qtquickcontrols2 qtgraphicaleffects qtsvg sddm-kcm qtdeclarative ];
    nativeBuildInputs = [ wrapQtAppsHook ];
    installPhase = ''
      mkdir -p $out/share/sddm/themes
      cp -aR $src/corners $out/share/sddm/themes/corners
    '';
    
    src = fetchFromGitHub {
      owner = "aczw";
      repo = "sddm-theme-corners";
      rev = "${version}";
      sha256 = "kBrUXMY+5ygUe+9/4nkypFo/4bHGDSEJtptyOgwyOd0=";
    };
  };

  sddm-sugar-dark = stdenv.mkDerivation rec {
    pname = "sddm-sugar-dark";
    version = "ceb2c45";
    dontBuild = true;
    buildInputs = [ qtbase qtquickcontrols2 qtgraphicaleffects qtsvg sddm-kcm qtdeclarative ];
    nativeBuildInputs = [ wrapQtAppsHook ];
    installPhase = ''
      mkdir -p $out/share/sddm/themes
      cp -aR $src $out/share/sddm/themes/sugar-dark
    '';
    
    src = fetchFromGitHub {
      owner = "MarianArlt";
      repo = "sddm-sugar-dark";
      rev = "${version}";
      sha256 = "flOspjpYezPvGZ6b4R/Mr18N7N3JdytCSwwu6mf4owQ=";
    };
  };
}
