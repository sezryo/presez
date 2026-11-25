{ config, lib, pkgs, inputs, ... }:

{
  services.flatpak.enable = true;

  systemd.services.sober-install = {
    description = "Install Sober from Flathub";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      if flatpak info --system org.vinegarhq.Sober >/dev/null 2>&1; then
        exit 0
      fi

      flatpak remote-add --system --if-not-exists flathub \
        https://dl.flathub.org/repo/flathub.flatpakrepo
      flatpak install --system --noninteractive --assumeyes \
        flathub org.vinegarhq.Sober
    '';
  };
}
