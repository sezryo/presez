# What a built configuration says about itself.
#
# `yo` shows and edits the options under `modules.*`; this file turns the
# evaluated options and selection into plain data it can read, both from the
# running system (/etc/yo/state.json) and from the working tree.
{ lib, ... }:

let
  inherit (builtins) attrNames concatMap elem filter isAttrs isList listToAttrs map tryEval;
  inherit (lib) concatStringsSep getAttrFromPath isOption optionalAttrs removePrefix sort unique;

  # Only plain data survives the trip to JSON.
  jsonable = value:
    let
      probe = tryEval (builtins.deepSeq value (builtins.toJSON value));
    in
      probe.success;

  # How the option should be presented, and what it may be set to.
  shape = type:
    let
      name = type.name or "";
      payload = type.functor.payload or null;
      choices =
        if payload == null then [ ]
        else if isList payload then payload
        else payload.values or [ ];
      element = type.nestedTypes.elemType or null;
    in
      if name == "bool" then { kind = "bool"; }
      else if name == "enum" then { kind = "enum"; inherit choices; }
      else if name == "str" || name == "unique" || name == "path" then { kind = "string"; }
      else if name == "int" then { kind = "int"; }
      else if name == "listOf" && element != null && (element.name or "") == "enum" then {
        kind = "enums";
        choices =
          let inner = element.functor.payload or [ ];
          in if isList inner then inner else inner.values or [ ];
      }
      else if name == "listOf" && element != null && (element.name or "") == "str" then { kind = "strings"; }
      else { kind = "other"; };

  # Every option declared under `modules`, except the package selection itself.
  # `root` is the repository; files are reported relative to it, so that the
  # result does not change merely because the tree's store path did.
  optionsOf = { options, config, root }:
    let
      relative = file: removePrefix (toString root + "/") (toString file);
      walk = path: node:
        if isOption node then
          let
            value = getAttrFromPath path config;
            probe = tryEval value;
          in
            [ ({
              name = concatStringsSep "." path;
              description =
                let text = node.description or "";
                in if isAttrs text then text.text or "" else text;
              type = node.type.description or "";
              file = builtins.head (map relative (node.declarations or [ ]) ++ [ "" ]);
            }
            // shape node.type
            // optionalAttrs (probe.success && jsonable probe.value) { value = probe.value; }
            // optionalAttrs (node ? default && jsonable node.default) { default = node.default; }) ]
        else if isAttrs node then
          concatMap (name: walk (path ++ [ name ]) node.${name})
            (filter (name: !(path == [ ] && elem name [ "singleton" "empty" ])) (attrNames node))
        else
          [ ];
    in
      walk [ ] options;

  # The package variants in effect: { <package> = [ <variant> ... ]; }.
  selectionOf = modules:
    listToAttrs (concatMap (package:
      let
        variants = filter (variant: !(elem variant (modules.empty.${package} or [ ])))
          (sort (a: b: a < b) (unique modules.singleton.${package}));
      in
        if variants == [ ] then [ ] else [ { name = package; value = variants; } ]
    ) (attrNames modules.singleton));

in {
  inherit optionsOf selectionOf;
}
