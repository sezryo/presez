{ config, pkgs, ... }:

{  
  users.users = {
    sezrienne = {
      isNormalUser = true;
      extraGroups = [ "wheel" "input" "tss" "networkmanager"];
      shell = pkgs.xonsh;
    };
  };
  users.groups = {
    networkmanager.members = [ "sezrienne" ];
    libvirtd.members = [ "sezrienne" ];
  };

  # Must declare as a new user registers
  dotfiles.dir = "/home/sezrienne/presez";
  user.name = "sezrienne";
}
