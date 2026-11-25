{ config, lib, pkgs, inputs, ... }:

{
  # Upstream hides the native title bar on Linux by default
  # (CLAUDE_NATIVE_TITLEBAR=1 restores it), so no local patching is needed.
  home.packages = [
    inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
