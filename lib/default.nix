{ lib, ... } @ args:

let
  inherit (lib) makeExtensible attrValues foldr;

  _lib = self:
    let
      callLibs = file: import file ({ lib = self; } // args);
    in {
      legacy = callLibs ./legacy.nix;
      options = callLibs ./options.nix;
      units = callLibs ./units.nix;
      packages = callLibs ./packages.nix;
      sets = callLibs ./sets.nix;
      hosts = callLibs ./hosts.nix;
      state = callLibs ./state.nix;
      layout = { tree = import ./tree.nix; };
    };

  mine = makeExtensible _lib;
in
  mine.extend (self: super:
    foldr (a: b: a // b) {} (attrValues super))
