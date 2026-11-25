{ config, lib, pkgs, inputs, ... }:

let
  claude = inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default;
in

{
  home.packages = [ claude ];

  # Keep the earlier PATH entry used by desktop apps on the configured package.
  home.file.".local/bin/claude" = {
    source = "${claude}/bin/claude";
    force = true;
  };
}
