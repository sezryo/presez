# Environment Variables

{ pkgs, lib, ... }:

{
  environment.variables = rec {
    HOME = "/home/sezrienne";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    PRESEZ = "\${HOME}/presez";

    # PATH = [
    #   "\${XDG_BIN_HOME}"
    # ];
  };
}
