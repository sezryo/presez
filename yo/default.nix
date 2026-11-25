{ lib
, python3Packages
, wrapGAppsHook4
, gobject-introspection
, gtk4
, libadwaita
, adwaita-icon-theme
}:

python3Packages.buildPythonApplication {
  pname = "yo";
  version = "1.0.0";
  pyproject = true;

  src = lib.cleanSourceWith {
    src = ./.;
    filter = path: type: baseNameOf path != "__pycache__";
  };

  build-system = [ python3Packages.setuptools ];

  nativeBuildInputs = [ wrapGAppsHook4 gobject-introspection ];
  buildInputs = [ gtk4 libadwaita adwaita-icon-theme ];
  dependencies = [ python3Packages.pygobject3 ];

  # The tests ask Nix to evaluate files, which a build sandbox cannot do;
  # run them from the working tree with: python3 -m unittest discover yo/tests
  doCheck = false;

  # One wrapper for both Python and GTK.
  dontWrapGApps = true;
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postInstall = ''
    install -Dm644 data/org.presez.Yo.desktop -t $out/share/applications
    install -Dm644 data/org.presez.Yo.svg -t $out/share/icons/hicolor/scalable/apps
    install -Dm644 data/org.presez.Yo-symbolic.svg -t $out/share/icons/hicolor/symbolic/apps
  '';

  meta = {
    description = "The helper that manages this NixOS configuration";
    mainProgram = "yo";
    platforms = lib.platforms.linux;
  };
}
