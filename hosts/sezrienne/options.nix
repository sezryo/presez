{ config, pkgs, inputs, lib, options, ... }:

with lib;
let
  inherit (lib.mine) mkOpt mkOpt' mkOptStr;
in {
  options = with types; {
    sez = {
      name = mkOptStr "Yvette Meng";
      userName = mkOptStr "sezryo";
      homeName = mkOptStr "sezrienne";
      email = mkOptStr "sezrienne@proton.me";
      academicEmail = mkOptStr "ym401@cam.ac.uk";
    };
  };
}
