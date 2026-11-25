{ config, pkgs, lib, inputs, ... }:

{
  system.stateVersion = "22.05";

  services.logind.settings.Login.HandleLidSwitch = "ignore";

  user.defaultPublicKey = "D931EC7A9950B57B";
}
