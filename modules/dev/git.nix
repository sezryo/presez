{
  description = "Git, with the user identity from the profile, and the GitHub CLI";
  packages = [
    { git = [ "basic" "user" ]; }
    "gh"
  ];
}
