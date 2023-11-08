{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "opengl" "opencl"

{
  hardware.opengl = {
    extraPackages = with pkgs; [
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
  };
}
