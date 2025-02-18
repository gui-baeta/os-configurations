# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  lib,
  options,
  ...
}:

{
  # ===================================
  # Services
  # ===================================

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.rpcbind.enable = true;

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /storage/Pictures         pen-and-paper(rw,sync,no_subtree_check,no_root_squash)
  '';

  # Enable openSSH server
  services.openssh = {
    startWhenNeeded = true;
    enable = true;
    # require public key authentication for better security
    settings = {
      X11Forwarding = true;
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  hardware.bluetooth.enable = true;

  # ===================================
  # Boot and Kernel
  # ===================================

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "amd_iommu=pt"
    "iommu=soft"
    "pcie_aspm=off"
  ];
  boot.kernelModules = [
    "amdgpu"
    "btusb"
  ];
  boot.extraModulePackages = [ ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "amdgpu"
    "btusb"
  ];
  boot.initrd.kernelModules = [ "btusb" ];

  # To not need to retype Disk encryption password for each disk
  boot.initrd.luks.reusePassphrases = true;

  # Mount point for 1 TB HDD
  fileSystems = {
    # 1TB HDD
    "/storage" = {
      device = "/dev/disk/by-uuid/8c0cdb39-bc09-417b-a662-7ae9d1220927";
      fsType = "ext4";
    };
  };

  # Some system level tweaks
  boot.kernel.sysctl = {

    # Virtual Memory maximum allocation per process.
    # Improves compatibility with applications that allocate a lot of memory, like modern games
    "vm.max_map_count" = 2097152;

    # # The maximum receive socket buffer size in bytes
    # "net.core.rmem_max" = 4194304;

    # # The maximum send socket buffer size in bytes
    # "net.core.wmem_max" = 1048576;
  };

  # ===================================
  # Systemd
  # ===================================

  # Disable suspend entirely
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # ===================================
  # Network
  # ===================================

  networking.hostName = "light-bulb"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable IPv6 globally (May want to manually disable for each VPN connection, if the provider doesn't support it)
  networking.enableIPv6 = true;

  # Some Firewall Rules
  networking.firewall.allowedTCPPorts = [
    # Spotify - To sync local tracks from your filesystem with mobile devices
    # in the same network, need to open port 57621:
    57621
    # For BitTorrent
    51413

    # NFSv4
    2049
  ];

  networking.firewall.allowedUDPPorts = [
    # In order to enable discovery of Google Cast devices (and possibly other Spotify Connect devices) in the same network by the Spotify app, need to open UDP port 5353:
    5353
    # BitTorrent
    51413
  ];

  # ===================================
  # Input
  # ===================================

  # Enable device input support
  # Enabled by default in desktopManager.gnome
  services.libinput.enable = true;

  # Logitech Devices (Mouse, etc)
  hardware.logitech.wireless.enable = true;

  # ===================================
  # Localisation
  # ===================================

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_CTYPE = "pt_PT.UTF-8";
    LC_NUMERIC = "pt_PT.UTF-8";
    LC_TIME = "pt_PT.UTF-8";
    LC_COLLATE = "pt_PT.UTF-8";
    LC_MONETARY = "pt_PT.UTF-8";
    LC_PAPER = "pt_PT.UTF-8";
    LC_NAME = "pt_PT.UTF-8";
    LC_ADDRESS = "pt_PT.UTF-8";
    LC_TELEPHONE = "pt_PT.UTF-8";
    LC_MEASUREMENT = "pt_PT.UTF-8";
    LC_IDENTIFICATION = "pt_PT.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "pt";
    xkb.variant = "";
  };
  services.xserver.exportConfiguration = true;

  # Configure console keymap
  console.keyMap = "pt-latin1";

  # ===================================
  # GRAPHICS
  # ===================================

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "modesetting" ]; # Either this or "amdgpu-pro"

  # Enable Screen Sharing
  xdg.portal.wlr.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Disable the connector that lets the OS talk with
  # the Gnome browser extension
  services.gnome.gnome-browser-connector.enable = false;

  # Enable graphucs with OpenGL and Vulkan
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # For 32 bit applications

    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      # Enable Video Accelaration API
      libva

      # Graphics with AMD open-source drivers
      # amdvlk

      # OpenCL support through MESA
      mesa.opencl
      # FIXME
      # Note: at some point GPUs in the R600 family and newer
      # may need to replace this with the "rusticl" ICD;
      # and GPUs in the R500-family and older may need to
      # pin the package version or backport Clover
      # - https://www.phoronix.com/news/Mesa-Delete-Clover-Discussion
      # - https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/19385
    ];

    # For 32 bit applications
    # extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
  };

  # Most software has the HIP libraries hard-coded. You can work around it on NixOS by using:
  systemd.tmpfiles.rules =
    let
      rocmEnv = pkgs.symlinkJoin {
        name = "rocm-combined";
        paths = with pkgs.rocmPackages; [
          rocblas
          hipblas
          clr
        ];
      };
    in
    [ "L+    /opt/rocm   -    -    -     -    ${rocmEnv}" ];

  # # Most software has the HIP libraries hard-coded. You can work around it on NixOS by using:
  # systemd.tmpfiles.rules = [ "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}" ];

  hardware.cpu.amd.updateMicrocode = true;
  # NOTE Needed?
  # hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  # Enable Vulkan support with amdvlk drivers
  # hardware.amdgpu.amdvlk.enable = true;

  # Enable AMD OpenCL support
  hardware.amdgpu.opencl.enable = true;

  # Force radv
  environment.variables.AMD_VULKAN_ICD = "RADV";
  # # Or
  environment.variables.VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";

  # ===================================
  # Virtualisation
  # ===================================

  # Container virtualization functionality
  virtualisation.containers.enable = true;
  virtualisation.docker = {
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
    enable = true;
  };

  # VMs
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  virtualisation.spiceUSBRedirection.enable = true;
  # NOTE The ABOVE is same as THIS?
  # security.wrappers.spice-client-glib-usb-acl-helper.source = "${pkgs.spice-gtk}/bin/spice-client-glib-usb-acl-helper";

  # ===================================
  # Some programs
  # ===================================

  # Keys and Signing
  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
      enableBrowserSocket = false;
    };
  };

  # Fish shell
  programs.fish.enable = true;

  environment.pathsToLink = [ "/share/fish" ];

  # Set aliases across sessions
  programs.fish.shellAliases = lib.mkForce {
    gitwordschanged = ''nix-shell -p git --run "git diff --word-diff=porcelain HEAD | grep -e '^[-+][^-+]' | wc -w"'';
    gitwordsadded = ''nix-shell -p git --run "git diff --word-diff=porcelain HEAD | grep -e '^+[^-+]' | wc -w"'';
    list_profile_packages = "nix-store --query --requisites /run/current-system | cut -d- -f2- | sort -u";
  };

  # Direnv - To automatically setup nix shells when entering a project directory
  programs.direnv.enable = true;

  # NOTE Interesting
  # Git
  programs.git.enable = true;

  # Fix some linking problems
  programs.nix-ld.enable = true;

  # AMD GPU control app
  programs.corectrl.enable = true;

  programs.dconf.enable = true;

  # GSConnect
  programs.kdeconnect.enable = true;
  programs.kdeconnect.package = pkgs.gnomeExtensions.gsconnect;

  # ===================================
  # Steam/Games related
  # ===================================

  # Java - For Steam
  programs.java.enable = true;

  # Steam
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;

    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  programs.gamemode.enable = true;

  # Steam Package overrides
  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      extraProfile = ''unset VK_ICD_FILENAMES'';
      extraPkgs =
        pkgs: with pkgs; [
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
  programs.nix-ld.libraries =
    options.programs.nix-ld.libraries.default
    ++ (with pkgs; [
      stdenv.cc.cc
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
      alsa-lib
      expat
      # Needed for electron
      libdrm
      mesa
      libxkbcommon
    ]);

  # ===================================
  # Extra System Packages
  # ===================================

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Unofficial Amazon Games Launcher
    # nile

    # Epic Games/ GOG / Amazon Games Launcher Linux Alternative
    heroic

    # Logitech Devices GUI Manager
    solaar

    # Additional tools for game launching tweaks
    gamescope
    mangohud

    # Lutris
    (lutris.override {
      extraLibraries = pkgs: [
        # List library dependencies here
      ];

      extraPkgs = pkgs: [
        # List package dependencies here
      ];
    })

    # Eye Of Gnome Additional Packages
    gthumb
  ];

  # ===================================
  # User/Users Config
  # ===================================

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILKAU5lq//NVCZ7pNvCmDppdWuqqN7ctFFm3a6PasNzt guibaeta"
    ];
  };
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.guibaeta = {
    isNormalUser = true;
    description = "Guilherme Fontes";
    extraGroups = [
      "networkmanager"
      "wheel"
      "gamemode"
    ];
    shell = pkgs.fish;
    useDefaultShell = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILKAU5lq//NVCZ7pNvCmDppdWuqqN7ctFFm3a6PasNzt guibaeta"
    ];

    packages = with pkgs; [
      # Management Tools
      git

      # Browsers
      (pkgs.symlinkJoin {
        name = "firefox-overlay";
        paths = [ pkgs.firefox ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/firefox --set GTK_IM_MODULE xim
        '';
      })
      google-chrome
      brave

      # Note Taking
      obsidian

      # Multi-purpose Calculator App
      qalculate-gtk

      # MPV but pretty
      celluloid

      stremio

      # BitTorrent client
      fragments

      # Music/Songs recognition
      mousai

      # Keepass Client
      keepassxc

      # IDEs
      jetbrains.pycharm-professional
      # jetbrains.clion
      jetbrains.idea-ultimate

      # Socials
      signal-desktop
      discord

      # Meeting Apps
      zoom-us

      # Game Launchers
      cartridges
      prismlauncher # Minecraft Launcher

      # Office
      # freeoffice
      # hunspell
      # hunspellDicts.uk_UA
      # hunspellDicts.th_TH
      # onlyoffice-bin

      # helpful tools
      tldr
      eyedropper # Gtk based color picker

      # photo editing
      darktable

      # E-Reader
      foliate

      # Markdown editor
      apostrophe

      # Pomodoro App
      gnome-solanum

      # Audio Simple Wiring Tool
      helvum

      sticky-notes

      # Virtual Desktop Infrastructure Client
      # vmware-horizon-client
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
