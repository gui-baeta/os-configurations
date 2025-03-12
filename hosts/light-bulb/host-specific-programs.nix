{ pkgs, unstable-pkgs, ... }:
{
  # installed packages, system(-profile)-wide.
  # To search, run: `$ nix search wget`
  environment.systemPackages =
    (with pkgs; [
      #
      # a home for my games
      #     ...a game launcher that grabs games from other game launchers
      cartridges
      #
      # Minecraft Launcher
      prismlauncher
      # Unofficial Amazon Games Launcher
      # nile
      #
      # Epic Games/ GOG / Amazon Games Launcher Linux Alternative
      heroic
      #
      # to launch games, in a different way + more features (ex: fsr)
      gamescope
      mangohud
      #
      # Lutris
      (lutris.override {
        extraLibraries = pkgs: [
          # List library dependencies here
        ];

        extraPkgs = pkgs: [
          # List package dependencies here
        ];
      })
      #
      # can generate thumbnails and cache them - also an image viewer
      gthumb
    ])
    #
    # not-so-unstable pkgs go heeeeeeeeeeeere
    ++ (with unstable-pkgs; [
      #
      # another game launcher - (my understanding) purpose is to try to compile fixes and tweaks for games
      umu-launcher
      #
      # to manage proton/wine versions for Lutris. hassle-free
      protonplus
    ]);
}
