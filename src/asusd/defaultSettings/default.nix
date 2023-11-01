{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "asusd" "defaultSettings"

{
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
