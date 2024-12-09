# This file is based on https://github.com/TLATER/dotfiles/blob/7c09f2c1fd4b2ba96aeffe67435a05f076cfec48/checks/alejandra.nix
{ pkgs, lib, flake-inputs, }:
let
  inherit (lib) callPackageWith;
  mkTest = test:
    pkgs.stdenv.mkDerivation ({
      dontPatch = true;
      dontConfigure = true;
      dontBuild = true;
      dontInstall = true;
      doCheck = true;
    } // test);
  callPackage = callPackageWith (pkgs // {
    inherit flake-inputs mkTest;
    # Work around `self` technically being a store path when
    # evaluated as a flake - `builtins.filter` can otherwise not be
    # called on it.
    self = builtins.path {
      name = "dotfiles";
      path = flake-inputs.self;
    };
  });
in {
  # Linters and formatters
  alejandra = callPackage ./alejandra.nix { };
}
