{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.boot.kernel;
  inherit (lib.mine) mkOpt';
  packages = [ "stable" "latest" "zfs" ];
in {
  options.modules.boot.kernel = mkOpt' (enum packages) "latest" "Which kernel version to use, select latest for the mainline kernel, stable for the newest stable kernel and zfs for the newest zfs supportive kernel";
  
  config.boot = mkMerge [
    (mkIf (cfg == "stable") {
      kernelPackages = pkgs.linuxPackages;
    })
    (mkIf (cfg == "latest") {
      kernelPackages = pkgs.linuxPackages_latest;
    })
    (mkIf (cfg == "zfs") {
      kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    })
  ];
}
