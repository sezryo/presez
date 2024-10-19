
{ config, pkgs, lib, inputs, ... }:

{  
  user = {
    name = "sezrienne";
    hostName = "sezrix";
    devName = "sezryo";
    fullName = "Yvette Meng";
    email = "sezrienne@proton.me";
    academicEmail = "ym401@cam.ac.uk";
    defaultPublicKey = "D931EC7A9950B57B";
    yubikoId =  [ "17672095" ];
  };
  
  dotfiles.dir = "/home/sezrienne/presez";
}
      
