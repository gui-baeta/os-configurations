# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  userInf,
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
      rocmPackages.clr
      # Enable Video Accelaration API
      libva
      libvdpau
      vaapiVdpau
      libvdpau-va-gl

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
  # Or
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

  # Fish shell
  programs.fish.enable = true;

  environment.pathsToLink = [ "/share/fish" ];

  # Set aliases across sessions
  programs.fish.shellAliases = lib.mkForce {
    gitwordschanged = ''nix-shell -p git --run "git diff --word-diff=porcelain HEAD | grep -e '^[-+][^-+]' | wc -w"'';
    gitwordsadded = ''nix-shell -p git --run "git diff --word-diff=porcelain HEAD | grep -e '^+[^-+]' | wc -w"'';
    list_profile_packages = "nix-store --query --requisites /run/current-system | cut -d- -f2- | sort -u";
  };

  # Fix some linking problems
  programs.nix-ld.enable = true;

  # AMD GPU control app
  programs.corectrl.enable = true;

  programs.dconf.enable = true;

  # GSConnect
  programs.kdeconnect.enable = true;
  programs.kdeconnect.package = pkgs.gnomeExtensions.gsconnect;

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
      libuv
      libuvc
      libgudev
      speex
      libvdpau
      gst_all_1.gstreamer
      gst_all_1.gst-vaapi
      gst_all_1.gst-libav
      gst_all_1.gstreamermm
      gst_all_1.gst-devtools
      gst_all_1.icamerasrc-ipu6
      gst_all_1.gst-rtsp-server
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-ugly
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-base
      gst_all_1.icamerasrc-ipu6ep
      gst_all_1.gst-plugins-viperfx
      gst_all_1.icamerasrc-ipu6epmtl
      gst_all_1.gst-editing-services

      libxcrypt
      gamemode

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

  # User/Users Config
  # ===================================

  # root user can trust ssh-ers, for keys here
  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPOsqnGiiVWmJz2fy2gHny8umrzDvaRu1vmB0auoZjEd phineas.guifontes@gmail.com"
    ];
  };
  #
  # the user account
  users.users."${userInf.nick}" = {
    uid = userInf.uid;
    isNormalUser = true;
    description = "${userInf.name}";
    extraGroups = [
      "networkmanager"
      "wheel"
      "gamemode"
      "navidrome"
    ];
    shell = pkgs.fish;
    useDefaultShell = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPOsqnGiiVWmJz2fy2gHny8umrzDvaRu1vmB0auoZjEd phineas.guifontes@gmail.com"
    ];

    packages = with pkgs; [
      # firefox browser, wrapped with an argument.. I don't remember why....
      firefox
      #
      # chrome browser, for when websites don't like firefox
      google-chrome
      #
      # markdown note taking - similar to Notion
      obsidian
      #
      # feature-rich calculator - swiss army knife of a calculator
      qalculate-gtk
      #
      # to stream things
      stremio
      #
      # client for torrents
      fragments
      #
      # music recogniser - Similar to Shazam
      mousai
      #
      # Keepass Client
      keepassxc
      #
      # ♥ Jetbrains IDEs ♥
      #     ...will eventually just not have these.. I'm an Helix/vim boy now
      jetbrains.pycharm-professional
      jetbrains.idea-ultimate
      #
      # if need to zoooooooooom
      zoom-us
      # to talk, with friends? I think I have friends
      discord
      #
      # prints a tldr of programs
      tldr
      #
      # color picker
      eyedropper
      #
      # photo editing
      darktable
      #
      # (e-)reader app
      foliate
      #
      # useful to preview markdown
      apostrophe
      #
      # pomodoro app
      gnome-solanum
      #
      # easily wire audio ins and outs, visually
      helvum
      #
      # notes that stick
      sticky-notes
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
