{
  description = "the PureScript toolchain";
  packages = [
    "purescript"
    # "spago"
    "dhall"
    "dhall-nix"
    # "psc-package" # broken: installShellCompletion fails in current nixpkgs
  ];
}
