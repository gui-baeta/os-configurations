# Return a list of overlay functions
[
  # Add an overlay to create the "overlays" namespace
  (final: prev: {
    # Create the "overlays" namespace
    overlays = {
      # You can add your custom packages here
      gradual-pause = final.callPackage ./mpv/gradual-pause/package.nix { };

      # Add other custom packages
      # "my-package" = final.callPackage ../path/to/my-package.nix { };
    };
  })

  # You can add more overlays here
  # (import ./other-overlay.nix)
]
