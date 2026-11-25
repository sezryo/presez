{
  description = "systemd-boot as the boot loader";
  default = true;
  config = {
    boot = {
      tmp.cleanOnBoot = true;
      loader.systemd-boot = {
        enable = true;
        consoleMode = "auto";
      };
      loader.efi = {
        efiSysMountPoint = "/boot";
        canTouchEfiVariables = true;
      };
    };
  };
}
