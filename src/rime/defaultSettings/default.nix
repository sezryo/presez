{ config, pkgs, lib, ... }:

let
  onChange = ''
    rimeSettingChanged=1
  '';
in 
  
lib.mine.mkIfProfile config.modules "rime" "defaultSettings"

{
  /* home.activation.setupRimeCacheDirectory = lib.hm.dag.entryAfter [ "writeBoundary" "onFilesChange" ] ''
    if [[ -v rimeSettingChanged ]]; then
      rm -rf "${config.user.dataDir}/fcitx5/rime/build"
      fcitx5-remote -r
      fcitx5 -d --replace
    fi
  ''; */

  home.dataFile = {
    "fcitx5/rime/default.custom.yaml" = {
      inherit onChange;
      source = ./myRime/default.custom.yaml;
    };
    "fcitx5/rime/ipa_yunlong.dict.yaml" = {
      inherit onChange;
      source = ./myRime/ipa_yunlong.dict.yaml;
    };
    "fcitx5/rime/ipa_yunlong.schema.yaml" = {
      inherit onChange;
      source = ./myRime/ipa_yunlong.schema.yaml;
    };
  };
}
