{ lib, config, inputs, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit inputs; };
  nixpkgs.overlays = [
    inputs.rust-overlay.overlays.default
    inputs.nur.overlay
    inputs.emacs-overlay.overlay
  ];
  _module.args = {
    colourscheme = import ../../assets/colourschemes/catppuccin-frappe.nix;
  };
}
