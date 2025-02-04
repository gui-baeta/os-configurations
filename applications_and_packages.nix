{config, pkgs, lib, options, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable Nix Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];



  # Container virtualization functionality
  virtualisation.containers.enable = true;

  # KDE/GS Connect
  programs.kdeconnect.enable = true;
  programs.kdeconnect.package = pkgs.gnomeExtensions.gsconnect;

  # AMD GPU control app
  programs.corectrl.enable = true;

  # Git
  programs.git.enable = true;

  # DConf
  programs.dconf.enable = true;

  # Enable fixing of some linking problems
  programs.nix-ld.enable = true;

  # Fish shell
  programs.fish.enable = true;
  
  # Java - For Steam
  programs.java.enable = true;

  # Steam
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;

    #remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    #dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  programs.gamemode.enable = true;

  # Exclude some unwanted default packages
  services.xserver.excludePackages = [ pkgs.xterm ];
  environment.gnome.excludePackages = (with pkgs; [
              gnome-tour
              snapshot
            ]) ++ (with pkgs.gnome; [
              seahorse # password manager
              totem # video player
              gnome-maps
              gnome-music
              epiphany # web browser
              geary # email reader  
              gnome-contacts 
            ]);

  # Available fonts
  fonts.packages = with pkgs; [
    corefonts
    vistafonts

    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
  ];


  # Steam Package overrides
  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      extraProfile = ''unset VK_ICD_FILENAMES'';
      extraPkgs = pkgs: with pkgs; [
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
        dxvk
      ];
    };
  };

  # Extra Packages for Linking
  programs.nix-ld.libraries = options.programs.nix-ld.libraries.default ++ (with pkgs; 
      [ stdenv.cc.cc
        openssl
        xorg.libXcomposite
        xorg.libXtst
        xorg.libXrandr
        xorg.libXext
        xorg.libX11
        xorg.libXfixes
        libGL
        libva
        pipewire
        xorg.libxcb
        xorg.libXdamage
        xorg.libxshmfence
        xorg.libXxf86vm
        libelf
        
        # Required
        glib
        gtk2
        bzip2
        
        # Without these it silently fails
        xorg.libXinerama
        xorg.libXcursor
        xorg.libXrender
        xorg.libXScrnSaver
        xorg.libXi
        xorg.libSM
        xorg.libICE
        gnome2.GConf
        nspr
        nss
        cups
        libcap
        SDL2
        libusb1
        dbus-glib
        ffmpeg
        # Only libraries are needed from those two
        libudev0-shim
        
        # Verified games requirements
        xorg.libXt
        xorg.libXmu
        libogg
        libvorbis
        SDL
        SDL2_image
        glew110
        libidn
        tbb
        
        # Other things from runtime
        flac
        freeglut
        libjpeg
        libpng
        libpng12
        libsamplerate
        libmikmod
        libtheora
        libtiff
        pixman
        speex
        SDL_image
        SDL_ttf
        SDL_mixer
        SDL2_ttf
        SDL2_mixer
        libappindicator-gtk2
        libdbusmenu-gtk2
        libindicator-gtk2
        libcaca
        libcanberra
        libgcrypt
        libvpx
        librsvg
        xorg.libXft
        libvdpau
        gnome2.pango
        cairo
        atk
        gdk-pixbuf
        fontconfig
        freetype
        dbus
        alsaLib
        expat
        # Needed for electron
        libdrm
        mesa
        libxkbcommon ]);


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Epic Games/ GOG / Amazon Games Launcher Linux Alternative
    heroic

    # Logitech Devices GUI Manager
    solaar

    gnome.gnome-tweaks
    gnome.dconf-editor
    
    spotify
    
    vscode

    # GSConnect extensions
    gnomeExtensions.clipboard-history
    gnomeExtensions.blur-my-shell
    gnomeExtensions.caffeine
    gnomeExtensions.gsconnect

    # Some missing icons
    gnome3.adwaita-icon-theme

    # Additional tools for game launching tweaks
    gamescope
    mangohud

    # Lutris
    (lutris.override {
      extraLibraries =  pkgs: [
        # List library dependencies here
      ];

      extraPkgs = pkgs: [
        # List package dependencies here
      ];
    })

    # Wine
    # winetricks (all versions)
    winetricks
    # support both 32- and 64-bit applications
    wineWowPackages.stable

    # Development
    distrobox
    podman
    jetbrains.clion
    jetbrains.idea-ultimate

    # Markdown Viewer
    apostrophe

    # Eye Of Gnome Additional Packages
    gthumb

    # Temporary packages for thesis
    texliveFull
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
}