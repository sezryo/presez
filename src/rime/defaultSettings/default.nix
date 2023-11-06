{ config, pkgs, lib, ... }:

let
  rimeConfig =
    if config.i18n.inputMethod.enabled == "fcitx5"
    then "${config.user.dataDir}/fcitx5/rime"
    else if config.i18n.inputMethod.enabled == "ibus"
    then "${config.user.configDir}/ibus/rime"
    else throw "unable to determine rime config directory";
  onChange = ''
    rimeSettingChanged=1
  '';
in 
  
lib.mine.mkIfProfile config.modules.singleton "rime" "defaultSettings"

{
  home.activation.setupRimeCacheDirectory = lib.hm.dag.entryAfter [ "writeBoundary" "onFilesChange" ] ''
    if [[ -v rimeSettingChanged ]]; then
      rm -rf "${rimeConfig}/build"
      fcitx5-remote -r
      fcitx5 -d --replace
    fi
  '';

  home.file = {
    "${rimeConfig}/default.custom.yaml" = {
      inherit onChange;
      source = ./myRime/default.custom.yaml;
    };
    "${rimeConfig}/ipa_yunlong.dict.yaml" = {
      inherit onChange;
      source = ./myRime/ipa_yunlong.dict.yaml;
    };
    "${rimeConfig}/ipa_yunlong.schema.yaml" = {
      inherit onChange;
      source = ./myRime/ipa_yunlong.schema.yaml;
    };
  };
}
