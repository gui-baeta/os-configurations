{ config, pkgs, lib, options, ... }:

# TODO Separate programs between Desktop and Laptop

{
  # Ensure that we can find stuff with `man -k`
  documentation.man.generateCaches = true;

  programs = {
    # KDE/GS Connect
    kdeconnect.enable = true;
    kdeconnect.package = pkgs.gnomeExtensions.gsconnect;

    # AMD GPU control app
    corectrl.enable = true;

    # Git
    git.enable = true;

    # DConf
    dconf.enable = true;

    nix-index.enable = true;
    command-not-found.enable = false;

    # Enable fixing of some linking problems
    nix-ld.enable = true;

    # Fish shell with aliases across sessions
    fish = {
      enable = true;
      shellAliases = lib.mkForce {
        gitwordschanged = ''
          nix-shell -p git --run "git diff --word-diff=porcelain HEAD | grep -e '^[-+][^-+]' | wc -w"'';
        gitwordsadded = ''
          nix-shell -p git --run "git diff --word-diff=porcelain HEAD | grep -e '^+[^-+]' | wc -w"'';
        list_profile_packages =
          "alias --save nix-store --query --requisites /run/current-system | cut -d- -f2- | sort -u";
      };
    };

    # Direnv - To automatically setup nix shells when entering a project directory
    direnv.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Epic Games/ GOG / Amazon Games Launcher Linux Alternative
    heroic

    # Unofficial Amazon Games Launcher
    nile

    # Additional tools for game launching tweaks
    gamescope
    mangohud

    # Screen sharing compatibility with X11
    xwaylandvideobridge

    # Markdown Viewer
    apostrophe

    # Eye Of Gnome Additional Packages - generates thumbnails for photos
    gthumb

    # Office
    freeoffice
    hunspell
    hunspellDicts.uk_UA
    hunspellDicts.th_TH
    onlyoffice-bin

    # Logitech Devices GUI Manager
    solaar

    gnome-tweaks
    dconf-editor

    spotify

    vscode

    # GSConnect extensions
    gnomeExtensions.clipboard-history
    gnomeExtensions.blur-my-shell
    gnomeExtensions.caffeine
    gnomeExtensions.gsconnect

    # Some missing icons
    adwaita-icon-theme

    # Lutris
    (lutris.override {
      extraLibraries = pkgs:
        [
          # List library dependencies here
        ];

      extraPkgs = pkgs:
        [
          # List package dependencies here
        ];
    })

    # Wine
    # winetricks (all versions)
    winetricks
    # support both 32- and 64-bit applications
    wineWowPackages.stable
    dxvk

    # Development
    distrobox
    podman
    jetbrains.clion
    jetbrains.idea-ultimate

    # VMs
    spice-gtk

    nfs-utils
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
}
