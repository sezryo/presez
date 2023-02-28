{ pkgs, lib, ... }:

{
  # Still, cannot change the mode between integrated and hybrid
  services.supergfxd = {
    enable = true;
    settings = {
      "mode" = "Integrated";
      "vfio_enable" = true;
      "vfio_save" = true;
      "always_reboot" = true;
      "no_logind" = false;
      "logout_timeout_s" = 45;
      "hotplug_type" = "None";
    };
  };
}
