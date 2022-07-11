{ config, lib, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    shellAbbrs = {
      tree = "exa -TF"; l =  "exa -Fabl"; ls = "exa -F";
      cipher = "nix-hash --flat --base32 --type sha256";
    };
    functions = {
      born = "sudo nixos-rebuild switch --flake path:/home/sezrienne/presez#sezrienne";
      reborn = "cd ~/presez && nix flake update && born";
      add = "emacs /home/sezrienne/presez/le-symbolique/signs.nix";
      paripassu = "git add . && git commit -m 'refrain' && git push --force origin main ";
      fish_greeting = "echo '//@_@\\~~ich bin tot'";
      fish_prompt = lib.strings.removePrefix "function fish_prompt" 
        (lib.strings.removeSuffix "end\n" 
          (builtins.readFile ./incarnation-via-crucis/fish_prompt.fish));
    };
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fzf = { 
    enable = true;
    enableFishIntegration = true; 
  };
  
  home.packages = [ pkgs.starship ];
}
