{
  pkgs ? import <nixpkgs> {
    overlays = [ (import ./overlay.nix) ];
  },
  ...
}:

{
  # Export both the derivation and the overlay
  inherit (pkgs.mpvScripts) gradual-pause;
  overlay = import ./overlay.nix;
}
