{
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Modules in common
    ./programs.nix
    ./fonts.nix
    ./sound.nix
    ./overrides.nix
    ./quirks.nix

    # TODO Eventually, for created modules
    # ../modules
  ];

  # Necessary for opening links in gnome under certain conditions
  services.gvfs.enable = true;

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    # allowUnfreePredicate = true;

    allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "vmware-horizon-client"
      ];
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    # Automatic garbage collection weekly
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 10d";
    };

    # Make the nixpkgs flake input be used for various nix commands
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    registry.nixpkgs = {
      from = {
        id = "nixpkgs";
        type = "indirect";
      };
      to = {
        type = "path";
        path = pkgs.path;
        narHash = builtins.readFile (
          pkgs.runCommandLocal "get-nixpkgs-hash" {
            nativeBuildInputs = [ pkgs.nix ];
          } "nix-hash --type sha256 --sri ${pkgs.path} > $out"
        );
      };
      flake = inputs.nixpkgs;
    };
  };
}
