{ pkgs, lib, ... }:

{
  services.asusd = {
    enable = true;
    enableUserService = true;

    # This does not work, probably due to priority reason, need PR
    # animeConfig = lib.modules.importJSON ./anime.conf;
    # asusdConfig = lib.modules.importJSON ./asusd.conf;
    # auraConfig = lib.modules.importJSON ./aura.conf;
    # profileConfig = builtins.readFile ./profile.conf;
    # ledModesConfig = lib.modules.importTOML ./asusd-ledmodes.toml;
  };

  environment.etc =
    let
      myCfg = name: lib.mkForce {
        source = name;
        mode = "0644";
      };
    in {
      "asusd/anime.conf" = myCfg ./anime.conf;
      "asusd/asusd-ledmodes.toml" = myCfg ./asusd-ledmodes.toml;
      "asusd/asusd.conf" = myCfg ./asusd.conf;
      "asusd/aura.conf" = myCfg ./aura.conf;
      "asusd/profile.conf" = myCfg ./profile.conf;
  };
}
