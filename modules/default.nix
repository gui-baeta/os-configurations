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
      extra-substituters = [
        # Populated by the CI in ggml-org/llama.cpp
        "https://llama-cpp.cachix.org"

        # A development cache for nixpkgs imported with `config.cudaSupport = true`.
        # Populated by https://hercules-ci.com/github/SomeoneSerge/nixpkgs-cuda-ci.
        # This lets one skip building e.g. the CUDA-enabled openmpi.
        # TODO: Replace once nix-community obtains an official one.
        "https://cuda-maintainers.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      #
      # Verify these are the same keys as published on
      # - https://app.cachix.org/cache/llama-cpp
      # - https://app.cachix.org/cache/cuda-maintainers
      extra-trusted-public-keys = [
        "llama-cpp.cachix.org-1:H75X+w83wUKTIPSO1KWy9ADUrzThyGs8P5tmAbkWhQc="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];

      # NOTE: SHOULD BE ONLY IN DESKTOP
      # AMD ROCm and CUDA related
      # SEE: https://github.com/nixos-rocm/nixos-rocm
      extra-sandbox-paths = [
        "/dev/kfd"
        "/sys/devices/virtual/kfd"
        "/dev/dri/renderD128"
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
