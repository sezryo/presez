# The package engine.
#
# A package is selected by a profile or a set through
#
#   modules.singleton.<package> = [ "<variant>" ... ];
#
# unless something vetoes it through `modules.empty.<package>`.
#
# A package that needs configuring has a directory in src/. Each variant in it
# is an ordinary NixOS module that knows nothing about how it gets switched
# on: this file wraps it so that it only takes effect while it is selected.
#
# A package without a directory needs no file at all: its `basic` variant
# simply installs `pkgs.<package>` for the user.
{ lib, ... }:

let
  inherit (builtins) any attrNames concatMap concatStringsSep elem filter intersectAttrs isFunction toString;
  inherit (lib) attrByPath functionArgs genAttrs mkIf mkOption removeAttrs setFunctionArgs splitString unique;
  inherit (lib.types) attrsOf listOf str;

  tree = import ./tree.nix;

  # Is this variant in effect for the configuration being evaluated?
  selected = modules: package: variant:
    elem variant (modules.singleton.${package} or [ ])
    && !(elem variant (modules.empty.${package} or [ ]));

  # Attributes of a module that are structure rather than configuration.
  structural = [ "_class" "_file" "key" "disabledModules" "imports" "options" "freeformType" "require" ];

  # Wrap the module in `file` so that its configuration is conditional on the
  # (package, variant) pair being selected. Option declarations and imports,
  # should a package need them, are left unconditional.
  gate = package: variant: file:
    let
      module = import file;
      location = toString file;

      finish = args: body:
        let
          full = body ? config || body ? options;
          configuration = if full then body.config or { } else removeAttrs body structural;
        in
          { _file = location; key = location; }
          // intersectAttrs (genAttrs structural (_: null)) body
          // { config = mkIf (selected args.config.modules package variant) configuration; };
    in
      if isFunction module
      then setFunctionArgs (args: finish args (module args)) (functionArgs module)
      else args: finish args module;

  # The module that declares the selection options, loads every package in
  # `srcDir`, and provides the default for packages that have no directory.
  packagesModule = srcDir:
    let
      packages = tree.packages srcDir;

      # Does src/ define this variant?
      defined = package: variant:
        packages ? ${package} && any (v: v.name == variant) packages.${package}.variants;
    in
      { config, pkgs, ... }:
      let
        cfg = config.modules;

        # Every (package, variant) pair in effect.
        active = concatMap (package:
          map (variant: { inherit package variant; })
            (filter (selected cfg package) (unique cfg.singleton.${package}))
        ) (attrNames cfg.singleton);

        undefined = filter (pair: !(defined pair.package pair.variant)) active;

        # `basic` of a package without a file of its own: pkgs.<package>,
        # where the name may be a dotted path such as "kdePackages.dolphin".
        implicit = map (pair: pair.package) (filter (pair: pair.variant == "basic") undefined);
        resolve = package: attrByPath (splitString "." package) null pkgs;

        unknownVariants = filter (pair: pair.variant != "basic") undefined;
        unknownPackages = filter (package: resolve package == null) implicit;
      in {
        options.modules = {
          singleton = mkOption {
            type = attrsOf (listOf str);
            default = { };
            description = "Selected package variants, as { <package> = [ <variant> ... ]; }.";
          };
          empty = mkOption {
            type = attrsOf (listOf str);
            default = { };
            description = "Package variants to leave out even where something selects them.";
          };
        };

        imports = concatMap (package:
          map (variant: gate package variant.name variant.file) packages.${package}.variants
        ) (attrNames packages);

        config = {
          assertions = [
            {
              assertion = unknownVariants == [ ];
              message = "Selected package variants that do not exist under src/: "
                + concatStringsSep ", " (map (pair: "${pair.package}.${pair.variant}") unknownVariants);
            }
            {
              assertion = unknownPackages == [ ];
              message = "Selected packages that are neither in src/ nor in nixpkgs: "
                + concatStringsSep ", " unknownPackages;
            }
          ];

          home.packages = filter (package: package != null) (map resolve implicit);
        };
      };

in {
  inherit selected gate packagesModule;
}
