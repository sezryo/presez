{ config, lib, pkgs, inputs, ... }:

let
  upstream = inputs.claude-desktop.packages.${pkgs.system}.default;

  # Claude Desktop hardcodes titleBarStyle:"default" on Linux (showing a GTK
  # title bar), while using "hidden" on macOS. Binary-patch the app.asar to
  # change the ternary's "default" branch to "hidden" (same byte length).
  claude-desktop = pkgs.runCommand "claude-desktop-no-titlebar" {
    meta = upstream.meta;
  } ''
    cp -r ${upstream} $out
    chmod -R u+w $out

    # Patch wrapper: remove system title bar env, disable-features flag,
    # and rewrite the asar path to point to our patched copy
    sed -i \
      -e "/ELECTRON_USE_SYSTEM_TITLE_BAR/d" \
      -e "s| --disable-features=CustomTitlebar||" \
      -e "s|${upstream}/lib/claude-desktop/resources/app.asar|$out/lib/claude-desktop/resources/app.asar|" \
      $out/bin/claude-desktop

    # Binary-patch app.asar: ?"default": -> ?"hidden":  (same byte length)
    sed -i 's/?\"default\":/?\"hidden\": /g' \
      $out/lib/claude-desktop/resources/app.asar
  '';
in
lib.mine.mkIfProfile config.modules "claude-desktop" "basic"

{
  home.packages = [ claude-desktop ];
}
