{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.network.proxy;
  inherit (lib.mine) mkEnableOpt mkEnableOpt';
in {
  options.modules.network.proxy = {
    enable = mkEnableOpt "Whether to do proxy settings";
    clash.enable = mkEnableOpt "Whether to enable clash service";
    protonvpn.enable = mkEnableOpt "Whether to enable proton vpn service";
    proxychains.enable = mkEnableOpt "Whether to enable proxychains service";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      networking.proxy.default = "http://127.0.0.1:7890";
    }
    (mkIf cfg.clash.enable {
      modules.singleton = {
        clash = [ "basic" ];
        proxychains = [ "clash" ];
      };
    })
    (mkIf cfg.protonvpn.enable {
      modules.singleton = {
        protonvpn-cli = [ "basic" ];
        protonvpn-gui = [ "basic" ];
      };
    })
    (mkIf cfg.proxychains.enable {
      modules.singleton = {
        proxychains = [ "basic" ];
      };
    }) 
  ]);
}
