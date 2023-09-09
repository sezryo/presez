{ config, pkgs, lib, ... }:

{
  security = {
    pam = {
      services = {
        swaylock.text = "auth include login";
        # login.u2fAuth = true; # You don't want others unlock your laptop when you pee
        # sudo.u2fAuth = true; # Wait for Lain got her yubikey
      };
    };
  };
}
