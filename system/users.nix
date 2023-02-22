{ config, pkgs, ... }:

{  
  users.users = {
    sezrienne = {
      isNormalUser = true;
      extraGroups = [ "wheel" "input" ];
      shell = pkgs.bash;
    };
  };

  users.groups."networkmanager".members = [ "sezrienne" ];
}
