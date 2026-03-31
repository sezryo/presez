{ config, lib, pkgs, inputs, ... }:

let
  # Override chromium to enable PipeWire camera support on Wayland.
  # The NixOS wrapper passes commandLineArgs via --add-flags, which is the
  # only reliable way to set Chromium feature flags (chromium-flags.conf is
  # not read by the NixOS wrapper).
  chromiumWithCamera = pkgs.chromium.override {
    commandLineArgs = builtins.concatStringsSep " " [
      "--enable-features=WebRTCPipeWireCapturer"
      "--enable-wayland-ime=true"
    ];
  };
in
lib.mine.mkIfProfile config.modules "chromium" "basic"

{
  home.packages = [ chromiumWithCamera ];
  environment.systemPackages = [ chromiumWithCamera ];

  programs.chromium = {
    enable = true;
    extraOpts = {
      "VideoCaptureAllowedUrls" = [ "https://teams.microsoft.com" "https://*.teams.microsoft.com" ];
    };
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
