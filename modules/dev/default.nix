{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    ./agda.nix
    ./bundle.nix
    ./clojure.nix
    ./c.nix
    ./coq.nix
    ./elixir.nix
    ./emacs.nix
    ./git.nix
    ./haskell.nix
    ./lean.nix
    ./nix.nix
    ./ocaml.nix
    ./purescript.nix
    ./python.nix
    ./racket.nix
    ./ruby.nix
    ./rust.nix
    ./scala.nix
    ./scheme.nix
    ./tex.nix
    ./typescript.nix
  ];
}
