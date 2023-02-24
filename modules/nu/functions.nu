# shellAbbrs
alias cipher = nix-hash --flat --base32 --type sha256
alias e = emacs -nw
alias sy = systemctl
alias ssy = sudo systemctl
alias lt = lsd --tree
alias l = lsd -Fal

# System Rolling(?), n.b. some args only suitable for sezrienne
def jr [
  --ueno (-u) # Update nix flake
  --shinjuku (-s) # Rebuild the system packages
  --kanda (-k) # Garbage collection
  --akihabara (-a) # Thorough garbage collection, incl. root level
] {
  cd /home/sezrienne/presez;
  if $ueno {sudo nix flake update;}
  if $shinjuku {sudo nixos-rebuild switch --flake 'path:./#sezrienne';}
  if $kanda {nix-store --gc}
  if $akihabara {sudo nix-collect-garbage -d}
}

# Maarui midorino yamanotesen
def yamanote [flags: string] {
    nu -c ("jr " + $flags);
    let code = (echo $env.LAST_EXIT_CODE)
    if ($code != 0 and $code != -1) {
       yamanote $flags
    }
}

# Adding new packages, n.b. some args only suitable for sezrienne
def tube [
  name: string
  --oyster (-o) # Use your Oyster card! (Direct into the corresponding list after adding)
  --hammersmith (-h) # Installing packages in home level
  --southKensington (-s) # Installing packages in system level
  --holborn (-H) # Adding home.packages
  --embankment (-E) # Adding environment.Systempackages
  --piccadilly (-P) # Adding programs.enable
  --southwark (-S) # Adding services.enable
] {
  let file = if $hammersmith {"home.nix"} else {"default.nix"}
  cd /home/sezrienne/presez/modules; mkdir $name; cd $name;
  if $holborn {nu -c ('echo "{ pkgs, lib, ... }:\n\n{\n  home.packages = [ pkgs." ' + $name + ' " ];\n}" | str collect | save ' + $file);}
  if $embankment {nu -c ('echo "{ pkgs, lib, ... }:\n\n{\n  environment.systemPackages = [ pkgs." ' + $name + ' " ];\n}" | str collect | save ' + $file);}
  if $piccadilly {nu -c ('echo "{ pkgs, lib, ... }:\n\n{\n  programs." ' + $name + ' " = {\n    enable = true;\n  };\n}" | str collect | save ' + $file);}
  if $southwark {nu -c ('echo "{ pkgs, lib, ... }:\n\n{\n  services." ' + $name + ' " = {\n    enable = true;\n  };\n}" | str collect | save ' + $file);}
  if $oyster {
    if $hammersmith {reform --lh}
    if $southKensington {reform --ls}
  }
}

# Git shortcout
def trinity [comment: string] {git add .; git commit -m $comment; git push --force origin main}

# Change the config files, n.b. some args only suitable for sezrienne
def reform [
  --emacs (-e) # Use emacs non-nw, defaultly use emacs -nw
  --vim (-v) # Use vim non-nw, defaultly use emacs -nw
  --system (-s): string # Configure system modules files in ~/presez/modules
  --home (-h): string # Configure home modules files in ~/presez/modules
  --nc # Nushell config
  --ne # Nushell env
  --nf # Nushell functions
  --hy # Hyprland config file
  --doom # Doom emacs config
  --lh # Change homeCommon package list
  --ls # Change systemCommon package list
] {
  let ed = if $emacs {"emacs "} else {if $vim {"vim "} else {"emacs -nw "}}
  if ($system != null) {nu -c ($ed + "/home/sezrienne/presez/modules/" + $system + "/default.nix")}
  if ($home != null) {nu -c ($ed + "/home/sezrienne/presez/modules/" + $home + "/home.nix")}
  if $nc {nu -c ($ed + "/home/sezrienne/presez/modules/nu/config.nu")}
  if $ne {nu -c ($ed + "/home/sezrienne/presez/modules/nu/env.nu")}
  if $nf {nu -c ($ed + "/home/sezrienne/presez/modules/nu/functions.nu")}
  if $hy {nu -c ($ed + "/home/sezrienne/presez/modules/hyprland/myHypr.conf")}
  if $doom {nu -c ($ed + "/home/sezrienne/.doom.d/init.el")}
  if $lh {nu -c ($ed + "/home/sezrienne/presez/lists/sezrienneList.nix")}
  if $ls {nu -c ($ed + "/home/sezrienne/presez/lists/systemList.nix")}
}

# Realise doom emacs files. WARNING: This is tend to be deprecated by purely managed by nix
def doom [name: string] {nu -c ("/home/sezrienne/.emacs.d/bin/doom " + $name)}

# Searching convenience
def "wikt" [name: string] {firefox ('en.wiktionary.org/wiki/' + $name)}
def "ggl" [name: string] {firefox ('google.com/search?client=firefox-b-d&q=' + $name)}

# Asus stuffs related
def "manifest" [image: string] {["/home/sezrienne/zauber/static/", $image, ".png"] | str collect | asusctl anime image -p $in}
def dgpuon [] {supergfxctl -m hybrid}
def dgpuoff [] {supergfxctl -m integrated}
