{ config, pkgs, ... }:

{  
  users.users = {
    sezrienne = {
      isNormalUser = true;
      extraGroups = [ "wheel" "input" "libvirtd" "tss" ];
      shell = pkgs.xonsh;
    };
  };

  users.groups."networkmanager".members = [ "sezrienne" ];
}
