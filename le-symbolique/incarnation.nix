{ config, lib, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    shellAbbrs = {
      see = "exa -TFl"; spec = "exa -TFal"; l = "exa -Fabl"; ls = "exa -F";
      cipher = "nix-hash --flat --base32 --type sha256";
      dc = "trash"; # Discard artifacts
      s = "sudo"; e = "emacs";
    };
    functions = {
      # The Lord related
      born = "sudo nixos-rebuild switch --flake path:/home/sezrienne/presez#sezrienne";
      reborn = "cd ~/presez && sudo nix flake update && born";
      mort = "shutdown -h now";
      die = "systemctl suspend";
      baptism = "shutdown -r now";

      paripassu = "git add . && git commit -m 'refrain' && git push --force origin main ";
      reformation = "~/.emacs.d/bin/doom sync";

      # Ego conversion
      add = "emacs /home/sezrienne/presez/le-symbolique/signs.nix";
      incarnate = "emacs /home/sezrienne/presez/le-symbolique/incarnation.nix";
      reform = "emacs /home/sezrienne/presez/le-symbolique/scripture-via-crucis/init.el";

      # Marine stuffs
      fish_greeting = "echo '//@_@\\~~ich bin tot'";
      fish_prompt = lib.strings.removePrefix "function fish_prompt" 
        (lib.strings.removeSuffix "end\n" 
          (builtins.readFile ./incarnation-via-crucis/fish_prompt.fish));

      # Use Substitutes
      rm = "echo 'Do not be a TERRORIST!'";
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
  
  home.packages = with pkgs; [ busybox starship ];
}
