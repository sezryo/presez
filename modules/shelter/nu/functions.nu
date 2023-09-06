# shellAbbrs
alias sy = systemctl
alias ssy = sudo systemctl
alias lt = lsd --tree
alias l = lsd -Fal
alias cheers = sudo systemctl restart NetworkManager

# System Rolling(?), n.b. some args only suitable for sezrienne
def jr [
  --ueno (-u) # Update nix flake
  --shinjuku (-s) # Rebuild the system packages
  --kanda (-k) # Garbage collection
  --akihabara (-a) # Thorough garbage collection, incl. root level
  --takadanobaba (-t) # Add an --show-trace flag
] {
  cd /home/sezrienne/presez;
  let debug = if $takadanobaba {" --show-trace"} else {""}
  if $ueno {nu -c ('sudo nix flake update' + $debug);}
  if $shinjuku {nu -c ('sudo nixos-rebuild switch --flake "path:./#sezrienne"' + $debug);}
  if $kanda {nu -c ('nix-store --gc' + $debug);}
  if $akihabara {nu -c ('sudo nix-collect-garbage -d' + $debug);}
}

# Maarui midorino yamanotesen
def yamanote [flags: string] {
     nu --config "/home/sezrienne/presez/modules/shelter/nu/functions.nu" -c ("jr " + $flags) | complete | if ($in.exit_code != 0 and $in.exit_code != -1) {yamanote $flags}
}

# Adding new packages, n.b. some args only suitable for sezrienne
def tube [
  name: string
  --oyster (-o) # Use your Oyster card! (Direct into the corresponding list after adding)
  --contactless (-c) # TfL loves contactless payment! (Direct into the created config file)
  --hammersmith (-h) # Installing packages in home level
  --southKensington (-s) # Installing packages in system level
  --holborn (-H) # Adding home.packages
  --embankment (-E) # Adding environment.Systempackages
  --piccadilly (-P) # Adding programs.enable
  --southwark (-S) # Adding services.enable
] {
  let file = {"default.nix"}
  cd /home/sezrienne/presez/modules;
  if $hammersmith { cd shelter; } else { cd system; }
  mkdir $name; cd $name;
  if $holborn {nu -c ('echo "{ pkgs, lib, ... }:\n\n{\n  home.packages = [ pkgs." ' + $name + ' " ];\n}" | str join | save default.nix');}
  if $embankment {nu -c ('echo "{ pkgs, lib, ... }:\n\n{\n  environment.systemPackages = [ pkgs." ' + $name + ' " ];\n}" | str join | save default.nix');}
  if $piccadilly {nu -c ('echo "{ pkgs, lib, ... }:\n\n{\n  programs." ' + $name + ' " = {\n    enable = true;\n  };\n}" | str join | save default.nix');}
  if $southwark {nu -c ('echo "{ pkgs, lib, ... }:\n\n{\n  services." ' + $name + ' " = {\n    enable = true;\n  };\n}" | str join | save default.nix');}
  if $contactless {
    if $hammersmith {rf -h $name}
    if $southKensington {rf -s $name}
  }
  if $oyster {
    if $hammersmith {rf --ph}
    if $southKensington {rf --ps}
  }
}

# Nixpkgs search shortcut
def ratp [
  name: string
  --trocadero (-t) # Use terminal prompts to search
  --pyramides (-p) # Search packages in search.nixos.org
  --opera (-o) # Search options in search.nixos.org
  --hotelDeVille (-h) # Search options in home manager archive
] {
  if $trocadero {nu -c ("nix search 'nixpkgs#" + $name)}
  if $pyramides {firefox ('search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=' + $name)}
  if $opera {firefox ('search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=' + $name)}
  if $hotelDeVille {firefox 'rycee.gitlab.io/home-manager/options.html'}
}

# Git shortcout
def trinity [comment: string] {git add .; git commit -S -m $comment; git push --force origin main}

# Change the config files, n.b. some args only suitable for sezrienne; rf stands for reform 
def rf [
  --vim (-v) # Use vim, defaultly use emacs
  --emacs (-e) # Does not hide the current terminal while launching emacs
  --bat (-b) # Bat, for exhibition
  --system (-s): string # Configure system modules files in ~/presez/modules
  --home (-h): string # Configure home modules files in ~/presez/modules
  --nc # Nushell config
  --nf # Nushell functions
  --em # Emacs inits
  --hy # Hyprland config file
  --ph # Change home package list
  --ps # Change system package list
] {
  let ed = if $bat {"bat "} else { if $vim {"vim "} else { if $emacs {"wezterm cli spawn --cwd (pwd); emacsclient -c "} else {"hyprctl dispatch movetoworkspacesilent special; emacsclient -c "}}}
  if ($system != null) {nu -c ($ed + "/home/sezrienne/presez/modules/system" + $system + "/default.nix")}
  if ($home != null) {nu -c ($ed + "/home/sezrienne/presez/modules/shelter" + $home + "/default.nix")}
  if $nc {nu -c ($ed + "/home/sezrienne/presez/modules/shelter/nu/config.nu")}
  if $nf {nu -c ($ed + "/home/sezrienne/presez/modules/shelter/nu/functions.nu")}
  if $hy {nu -c ($ed + "/home/sezrienne/presez/modules/shelter/hyprland/myHypr.conf")}
  if $ph {nu -c ($ed + "/home/sezrienne/presez/hosts/sezrienne/home/packages.nix")}
  if $ps {nu -c ($ed + "/home/sezrienne/presez/hosts/sezrienne/packages.nix")}
  if $em {nu -c ($ed + "/home/sezrienne/presez/modules/shelter/emacs/inits/init.el")}
}

# Emacs forever!!! This is to hide the current terminal while launching emacs
def ee [name: string] {hyprctl dispatch movetoworkspacesilent special; emacsclient -c $name;}
# This is to spawn a new terminal tab while launching emacs, syntax follows nushell
def e [name: string] {wezterm cli spawn --cwd (pwd); emacsclient -c $name;}

# Some useful tools
def cipher [name: string] {nu -c ("nix-hash --flat --base32 --type sha256 " + $name)}
def doxx [name: string] {nu -c ("rg -rnw . -e " + $name)}

# Searching convenience
def wikt [name: string] {firefox ('en.wiktionary.org/wiki/' + $name)}
def ggl [name: string] {firefox ('google.com/search?client=firefox-b-d&q=' + $name)}

# Asus stuffs related
def manifest [image: string] {["/home/sezrienne/zauber/static/", $image, ".png"] | str join | asusctl anime image -p $in}
def dgpuon [] {supergfxctl -m hybrid}
def dgpuoff [] {supergfxctl -m integrated}