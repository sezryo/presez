{ config, pkgs, ... }:

{
  boot = {
    # initrd.prepend = [ "${./acpi_override}" ];
    # kernelParams = [ "mem_sleep_default=deep" ];
    # kernelParams = [ "early_initrd=acpi_override" "mem_sleep_default=deep" ];
    # kernelParams = [ "acpi_osi=" ];
    initrd.kernelModules = [ "amdgpu" ];
  };
}
