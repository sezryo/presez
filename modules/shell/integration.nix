{
  description = "essential shell integrations";
  packages = [
    "zoxide"
    "fzf"
    { starship = [ "basic" "catppuccin" ]; }
    "zellij"
    "direnv"
  ];
}
