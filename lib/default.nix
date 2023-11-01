{ lib, ... } @ args:

with lib;
with builtins;

let _lib = self:
  let
    callLibs = file: import file ({ lib = self; } // args);
  in {
    legacy = callLibs ./legacy.nix;
    importers = callLibs ./importers.nix;
    options = callLibs ./options.nix;
    units = callLibs ./units.nix;
  };
  mine = makeExtensible _lib;
in
  mine.extend (self: super:
    foldr (a: b: a // b) {} (attrValues super))
          
