{ config, pkgs, lib, ... }:

{
  imports =
    [ 
      ../../was/ga402
      ../../wie
      ../../wer
      ../../wo
    ];
  
  system.stateVersion = "22.05";

}

