{ config, pkgs, ... }:

{
  systemd.services.clash = {
    description = "Clash client service, using clash-meta";
    wantedBy = [ "multi-user.target" ]; 
    after = [ "network.target" ];
    serviceConfig = {
      Type = "simple";
      User = "root";
      ExecStart = "${pkgs.clash-meta}/bin/clash-meta -d /home/sezrienne/.config/clash/";
      Restart = "on-failure";
      RestartPreventExitStatus = "23";
    };
  };

  networking.proxy.default = "http://127.0.0.1:7890"; 

  programs.proxychains = {
    enable = false;
    proxies."clash" = {
      enable = true;
      type = "http";
      host = "127.0.0.1";
      port = 7890;
    };
  };

  environment.systemPackages = with pkgs; [
    clash-meta
  ];

  # nix.settings.substituters = [ "https://mirror.tuna.tsinghua.edu.cn/nix-channels/store" ];

}
