{ lib, ... }:

let
  inherit (lib) mkIf mkMerge;

  mkIfElse = p: yes: no: mkMerge [
    (mkIf p yes)
    (mkIf (!p) no)
  ];

  # Gate a configuration derivation on the singleton/empty module system.
  # Enables `drv` iff `component` is listed in `base.singleton.${src}`
  # and not excluded by `base.empty.${src}`.
  mkIfProfile = base: src: component: drv:
    let
      inSingleton = base.singleton ? ${src} && builtins.elem component base.singleton.${src};
      inEmpty = base.empty ? ${src} && builtins.elem component base.empty.${src};
    in
      mkIf (inSingleton && !inEmpty) drv;

  # Higher-order module constructor for src/ packages.
  # Takes a package name, variant name, and a function (args -> config),
  # returns a NixOS module gated by mkIfProfile.
  #
  # Usage in src/<pkg>/basic.nix:
  #   lib.mine.mkSrc "bat" "basic" ({ pkgs, ... }: {
  #     home.programs.bat.enable = true;
  #   })
  mkSrc = name: variant: f:
    { config, lib, pkgs, inputs, ... } @ args:
    lib.mine.mkIfProfile config.modules name variant (f args);

in {
  inherit mkIfElse mkIfProfile mkSrc;
}
