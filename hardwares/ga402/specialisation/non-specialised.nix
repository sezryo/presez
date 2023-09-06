{ lib, config, pkgs, ... }: {
  config = lib.mkIf (config.specialisation != {}) {
    # Config that should only apply to the default system, not the specialised ones

    # services.supergfxd.settings = {
    #   "mode" = "Hybrid";
    # };
  };
}
