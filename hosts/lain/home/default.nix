{ pkgs, lib, config, inputs, ... }:

let
  inherit (lib.mine) rakeLeaves;
  ich = rakeLeaves ./.;  
in {
  home-manager.users.lain = {
    imports = with ich; [
      env cursor git packages
    ];
    home.username = "lain";
    home.homeDirectory = "/home/lain";
    home.stateVersion = "22.05";  
    systemd.user.startServices = "sd-switch"; # Enforce to start user-level services after booting
  };
}
