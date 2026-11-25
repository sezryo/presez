{ config, pkgs, lib, inputs, ... }:

{
  system.stateVersion = "24.05";

  user.defaultPublicKey = "E1D631009F9086E1";

  # Preserve this host's existing greeter IDs across GDM's account renaming.
  users.users = {
    gdm-greeter-2.uid = lib.mkForce 60580;
    gdm-greeter-3.uid = lib.mkForce 60581;
    gdm-greeter-4.uid = lib.mkForce 60582;
    gdm-greeter-5.uid = lib.mkForce 60583;
  };
}
