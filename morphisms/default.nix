with import <nixpkgs> {};
with lib;
with builtins;
rec {

  copyDir = fromDir: toDir:
    mapAttrs'
      (name: value: nameValuePair (toDir + "/" + name)
                                      (fromDir + "/${name}"))
      (filterAttrs (name: value: value == "regular")
                       (readDir fromDir));
  copyDirRecursively = fromDir: toDir:
    foldl'
      (a: b: a // b)
      (copyDir fromDir toDir)
      (mapAttrsToList (name: value: copyDirRecursively (fromDir + "/${name}")
                                                           (toDir + "/" + name))
                          (filterAttrs (name: value: value == "directory")
                                           (readDir fromDir)));
  mkHomeFile = fromDir: toDir:
    mapAttrs'
      (name: value: nameValuePair name ({ source = value; }))
      (copyDirRecursively fromDir toDir);

  listDir = fromDir:
    mapAttrsToList (name: value: fromDir + "/${name}") (readDir fromDir);

  listDirContaining = fromDir: Text:
    filter (x: hasInfix Text (readFile x)) (listDir fromDir);

   useSigns = signsList:
    map (x: "/home/sezrienne/presez/signs/" + x) signsList;
}
