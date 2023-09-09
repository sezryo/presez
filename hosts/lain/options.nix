{ config, pkgs, inputs, lib, options, ... }:

with lib;
let
  inherit (lib.mine) mkOpt mkOpt' mkOptStr;
in {
  options = with types; {
    lain = {
      name = mkOptStr "Otonashi Rein";
      userName = mkOptStr "lain";
      homeName = mkOptStr "lain";
      email = mkOptStr "popiko229@gmail.com";
    };
  };
}
