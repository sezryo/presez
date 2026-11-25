{
  description = "automatic Nix garbage collection";
  config = {
    nix.gc = {
      automatic = true;
      randomizedDelaySec = "14m";
      options = "--delete-older-than 30d";
    };
  };
}
