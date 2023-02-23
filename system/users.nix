{ config, pkgs, ... }:

{  
  users.users = {
    sezrienne = {
      isNormalUser = true;
      extraGroups = [ "wheel" "input" ];
      shell = pkgs.xonsh;
    };
  };

  users.groups."networkmanager".members = [ "sezrienne" ];
}
