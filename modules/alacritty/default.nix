{ pkgs, lib, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      import = [ "/home/sezrienne/presez/modules/alacritty/init.yml" ];
    };
  };
}
