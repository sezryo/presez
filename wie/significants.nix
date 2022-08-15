{ config, pkgs, lib, ... }:

# These are signs used via systemwide configuration

with import ../morphisms;

{
  imports = useSigns [
    "steam"
    "flatpak"
  ];

}
