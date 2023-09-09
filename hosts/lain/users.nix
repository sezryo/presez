{ config, pkgs, ... }:

{  
  users.users = {
    lain = {
      isNormalUser = true;
      extraGroups = [ "wheel" "input" "tss" "networkmanager"];
      shell = pkgs.xonsh;
    };
  };
  users.groups = {
    networkmanager.members = [ "lain" ];
    libvirtd.members = [ "lain" ];
  };

  # Must declare as a new user registers
  dotfiles.dir = "/home/dotfiles/lain";
  user.name = "lain";
}
