# shellAbbrs
alias sy = systemctl
alias ssy = sudo systemctl
alias lt = lsd --tree
alias l = lsd -Fal
alias ec = emacsclient -c
alias en = emacs -nw
alias c = clear
alias cheers = sudo systemctl restart NetworkManager

# System Rolling, wait to be overwriten by a centralised client
def jr [
  --ueno (-u) # Update nix flake
  --shinjuku (-s) # Rebuild the system packages
  --kanda (-k) # Garbage collection
  --akihabara (-a) # Thorough garbage collection, incl. root level
  --takadanobaba (-t) # Add an --show-trace flag
] {
  cd $env.DOTFILES_TOP;
  let debug = if $takadanobaba {" --show-trace"} else {""}
  let user = $env.USER
  if $ueno {nu -c ('sudo nix flake update' + $debug);}
  if $shinjuku {nu -c ('sudo nixos-rebuild switch --flake path:./#' + $user + $debug);}
  if $kanda {nu -c ('nix-store --gc' + $debug);}
  if $akihabara {nu -c ('sudo nix-collect-garbage -d' + $debug);}
}

# Maarui midorino yamanotesen
def yamanote [flags: string] {
     nu --config ($env.HOME + "/.functions.nu") -c ("jr " + $flags) | complete | if ($in.exit_code != 0 and $in.exit_code != -1) {yamanote $flags}
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

# Emacs forever!!! This is to hide the current terminal while launching emacs
def ee [name: string] {hyprctl dispatch movetoworkspacesilent special; emacsclient -c $name;}
# This is to spawn a new terminal tab while launching emacs, syntax follows nushell
def e [name: string] {wezterm cli spawn --cwd (pwd); emacsclient -c $name;}

# Some useful tools
def cipher [name: string] {nu -c ("nix-hash --flat --base32 --type sha256 " + $name)}

# Searching convenience
def wikt [name: string] {firefox ('en.wiktionary.org/wiki/' + $name)}
def ggl [name: string] {firefox ('google.com/search?client=firefox-b-d&q=' + $name)}

# Asus stuffs related
def dgpuon [] {supergfxctl -m hybrid}
def dgpuoff [] {supergfxctl -m integrated}
