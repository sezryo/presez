{ pkgs, lib, ... }:

{
  services.asusd = {
    enable = true;
    enableUserService = true;
    animeConfig = lib.modules.importJSON ./anime.conf;
    asusdConfig = lib.modules.importJSON ./asusd.conf;
    auraConfig = lib.modules.importJSON ./aura.conf;
    profileConfig = builtins.readFile ./profile.conf;
    ledModesConfig = lib.modules.importTOML ./asusd-ledmodes.toml;
  };
}
