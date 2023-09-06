{ config, pkgs, lib, ... }:

{
  security = {
    pam = {
      services = {
        swaylock.text = "auth include login";
        # login.u2fAuth = true; # You don't want others unlock your laptop when you pee
        sudo.u2fAuth = true;
      };

      u2f = {
        authFile = config.age.secrets.u2f_keys.path;
      };
      
      yubico = {
        enable = true;
        debug = true;
        # control = "required"; # Uncomment to use MFA
        mode = "challenge-response";
        id = [ "17672095" ];
      };
    };
  };
}
