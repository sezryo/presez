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

  readRecursively = dir:
    concatStringsSep "\n"
      (mapAttrsToList (name: value: if value == "regular"
                                        then readFile (dir + "/${name}")
                                        else (if value == "directory"
                                              then readRecursively (dir + "/${name}")
                                              else [ ]))
                          (builtins.readDir dir));
  
  mkHomeFile = fromDir: toDir:
    mapAttrs'
      (name: value: nameValuePair name ({ source = mkDefault value; }))
      (copyDirRecursively fromDir toDir);

  listDir = fromDir:
    mapAttrsToList (name: value: fromDir + "/${name}") (readDir fromDir);

  listDirContaining = fromDir: Text:
    filter (x: hasInfix Text (readFile x)) (listDir fromDir);

  useSystemModules = modulesList:
    map (x: ../. + ("/modules/" + x)) modulesList;

  useHomeModules = modulesList:
    map (x: ../. + ("/modules/" + x + "/home.nix")) modulesList;

  transparentify = colour:
    "#00${substring 1 (stringLength colour - 1) colour}";
}
