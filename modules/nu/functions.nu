# shellAbbrs
alias cipher = (nix-hash --flat --base32 --type sha256)
alias e = emacs -nw
alias sy = systemctl
alias ssy = sudo systemctl
alias lt = lsd --tree
alias l = lsd -Fal

# System Rolling(?)
def jr [
  --ueno (-u) # Update nix flake
  --harajuku (-h) # Rebuild the home level packages
  --shinjuku (-s) # Rebuild the system level packages
  --kanda (-k) # Garbage collection
  --akihabara (-a) # Thorough garbage collection, incl. root level
] {
  cd /home/sezrienne/presez;
  if $ueno {sudo nix flake update;}
  if $harajuku {nix run home-manager --no-write-lock-file -- switch --flake './#nixos' --impure}
  if $shinjuku {sudo nixos-rebuild switch --flake 'path:./#nixos' --impure;}
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

# Adding new packages
def tube [
  name: string
  --oyster (-O) # Use your Oyster card! (Direct into the corresponding list after adding)
  --holborn (-h) # Adding home packages
  --embankment (-e) # Adding environment (system) packages
  --marylebone (-m) # Adding home modules (if there are)
  --southwark (-s) # Adding system services
] {
  cd /home/sezrienne/presez/modules; mkdir $name; cd $name;
  if $holborn {
    echo "{ pkgs, lib, ... }:\n\n{\n  home.packages = [ pkgs." $name " ];\n}" | str collect | save default.nix;
    if $oyster {reform --lhc}}
  if $embankment {
    echo "{ pkgs, lib, ... }:\n\n{\n  environment.systemPackages = [ pkgs." $name " ];\n}" | str collect | save default.nix;
    if $oyster {reform --lsc}}
  if $marylebone {
    echo "{ pkgs, lib, ... }:\n\n{\n  programs." $name " = {\n    enable = true;\n  };\n}" | str collect | save default.nix;
    if $oyster {reform --lhc}}
  if $southwark {
    echo "{ pkgs, lib, ... }:\n\n{\n  services." $name " = {\n    enable = true;\n  };\n}" | str collect | save default.nix;
    if $oyster {reform --lsc}}
}

# Git shortcout
def trinity [comment: string] {git add .; git commit -m $comment; git push --force origin main}

# Change the config files
def reform [
  --emacs (-e) # Use emacs non-nw, defaultly use emacs -nw
  --vim (-v) # Use vim non-nw, defaultly use emacs -nw
  --nuc # Nushell config
  --nue # Nushell env
  --nuf # Nushell functions
  --doom # Doom emacs config
  --lhc # Change homeCommon package list
  --lhi # Change homeInit package list
  --lsc # Change systemCommon package list
] {
  let ed = if $emacs {"emacs "} else {if $vim {"vim "} else {"emacs -nw "}}
  if $nuc {nu -c ($ed + "/home/sezrienne/presez/modules/nu/config.nu")}
  if $nue {nu -c ($ed + "/home/sezrienne/presez/modules/nu/env.nu")}
  if $doom {nu -c ($ed + "/home/sezrienne/.doom.d/init.el")}
  if $lhc {nu -c ($ed + "/home/sezrienne/presez/lists/homeCommonList.nix")}
  if $lhi {nu -c ($ed + "/home/sezrienne/presez/lists/homeInitList.nix")}
  if $lsc {nu -c ($ed + "/home/sezrienne/presez/lists/systemCommonList.nix")}
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
