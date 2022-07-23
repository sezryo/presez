with import <nixpkgs> {};
with lib;
rec {

  copyDir = fromDir: toDir:
    mapAttrs'
      (name: value: nameValuePair (toDir + "/" + name)
                                      (fromDir + "/${name}"))
      (filterAttrs (name: value: value == "regular")
                       (builtins.readDir fromDir));
  copyDirRecursively = fromDir: toDir:
    builtins.foldl'
      (a: b: a // b)
      (copyDir fromDir toDir)
      (mapAttrsToList (name: value: copyDirRecursively (fromDir + "/${name}")
                                                           (toDir + "/" + name))
                          (filterAttrs (name: value: value == "directory")
                                           (builtins.readDir fromDir)));
  mkHomeFile = fromDir: toDir:
    mapAttrs'
      (name: value: nameValuePair name ({ source = value; }))
      (copyDirRecursively fromDir toDir);

  listDir = fromDir:
    mapAttrsToList (name: value: fromDir + "/${name}") (builtins.readDir fromDir);

}
