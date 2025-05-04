# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  unstable-pkgs,
  lib,
  config,
  options,
  ...
}:

{
  services.rpcbind.enable = true;
  services.nfs.server.enable = true;
  # systemd.mounts = [
  #   {
  #     type = "nfs";
  #     mountConfig = {
  #       Options = "noatime";
  #     };
  #     what = "light-bulb:/storage/Pictures";
  #     where = "/mnt/NFS-Pictures";
  #   }
  # ];
  # systemd.automounts = [
  #   {
  #     wantedBy = [ "multi-user.target" ];
  #     automountConfig = {
  #       TimeoutIdleSec = "600";
  #     };
  #     where = "/mnt/NFS-Pictures";
  #   }
  # ];

  # Bootloader.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_6_11.override {
  #   argsOverride = rec {
  #     src = pkgs.fetchurl {
  #           url = "mirror://kernel/linux/kernel/v4.x/linux-${version}.tar.xz";
  #           sha256 = "01rafnqal2v96dzkabz0irymq4sc9ja00ggyv1xn7yzjnyrqa527";
  #     };
  #     version = "6.11.5";
  #     modDirVersion = "6.11.5";
  #     };
  # });

  boot.kernelParams = [
    #
    # No need to set "cik_support" or "si_support" sub flags of "amdgpu"/"radeon"
    # since my GPU is "renoir", of Vega series (2020)
    #

    #
    # Override for dynamic power management setting (0 = disable, 1 = enable)
    # The default is -1 (auto).
    # NOTE DISABLING THIS TO SEE IF BATTERY AUTONOMY IMPROVES
    # "amdgpu.dpm=1"
    #
    # Override the default ABM (Adaptive Backlight Management) level used for DC enabled hardware.
    # Requires DMCU to be supported and loaded. Valid levels are 0-4.
    # A value of 0 indicates that ABM should be disabled by default. Values 1-4 control the maximum allowable brightness reduction via the ABM algorithm, with 1 being the least reduction and 4 being the most reduction.
    # Defaults to -1, or auto. Userspace can only override this level after boot if it’s set to auto.
    "amdgpu.abmlevel=0"

    # =======
    # Override display features enabled.
    #
    # See enum DC_DEBUG_MASK in drivers/gpu/drm/amd/include/amd_shared.h:
    #     https://docs.kernel.org/gpu/amdgpu/driver-core.html#c.DC_DEBUG_MASK
    # Source Code:
    #     https://github.com/torvalds/linux/blob/master/drivers/gpu/drm/amd/include/amd_shared.h#L259
    # =======
    #
    # If set, disable Panel self refresh v1 and PSR-SU
    "amdgpu.dcdebugmask=0x10" # (DC_DISABLE_PSR)
    # Just in case, disable PSR-SU specifically
    # Disable PanelSelfRrefresh2 with the following kernel parameter amdgpu.dcdebugmask=0x200
    # eDP display is the display my laptop uses, you can check it by running xrandr
    "amdgpu.dcdebugmask=0x200" # (DC_DISABLE_PSR_SU)
    #
    # Stutter mode is a power saving feature on GPUs
    # If set, disable memory stutter mode
    # NOTE DISABLING THIS TO SEE IF BATTERY AUTONOMY IMPROVES
    # "amdgpu.dcdebugmask=0x2" # (DC_DISABLE_STUTTER)

    #
    # Disable panel fractional PWM
    # Some LED panel drivers might not like fractional PWM, and backlight flickering may be observed.
    # Disabled by default
    "amdgpu.dcfeaturemask=0x4" # (DC_DISABLE_FRACTIONAL_PWM_MASK)
  ];
  boot.kernelModules = [
    "amdgpu"
    "kvm-amd"
  ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [
    "nfs" # For NFS Client to work
    "btrfs"
    "ext"
    "vfat"
  ];

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [
    "rtsx_pci_sdmmc"
    "dm_thin_pool"
    "dm-snapshot"
    "xhci_pci"
    "sdhci_pci"
    "ahci"
    "nvme"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "sr_mod"
    "nfs"
    "amdgpu"
  ];

  networking.hostName = "pen-and-paper"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  #
  # Video drivers for X
  # Should not use "amdgpu", useful when no compositor is used.
  # See: https://github.com/NixOS/nixpkgs/pull/218437
  # "modesetting" (Kernel Mode Setting) uses Mesa drivers directly
  services.xserver.videoDrivers = [ "modesetting" ];

  # Enable Screen Sharing
  xdg.portal.wlr.enable = true;

  # Keys and Signing
  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
      enableBrowserSocket = false;
    };
  };

  # Fix some linking problems
  programs.nix-ld.enable = true;

  # AMD GPU control app
  programs.corectrl.enable = true;

  programs.dconf.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Disable the connector that lets the OS talk with
  # the Gnome browser extension
  services.gnome.gnome-browser-connector.enable = false;

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "pt";
    xkb.variant = "";
  };
  services.xserver.exportConfiguration = true;

  # Configure console keymap
  console.keyMap = "pt-latin1";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  services.libinput.touchpad.tapping = true;

  sops.secrets.user_password = { };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.guibaeta = {
    uid = 1000;
    isNormalUser = true;
    description = "Guilherme Fontes";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
    useDefaultShell = true;
    hashedPasswordFile = config.sops.secrets.user_password.path;

    packages =
      (with pkgs; [
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

        # Note Taking
        obsidian

        # Multi-purpose Calculator App
        qalculate-gtk

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

        # helpful tools
        tldr
        eyedropper # Gtk based color picker

        # photo editing
        darktable

        # E-Reader
        foliate

        # Markdown editor
        apostrophe

        # photo editing
        darktable

        # Pomodoro App
        gnome-solanum

        # Audio Simple Wiring Tool
        helvum

        sticky-notes
      ])
      ++ (with unstable-pkgs; [
        # remote desktop client
        vmware-horizon-client
      ]);
  };

  # Some Firewall Rules
  networking.firewall.allowedTCPPorts = [
    # Spotify - To sync local tracks from your filesystem with mobile devices
    # in the same network, need to open port 57621:
    57621
    # For BitTorrent
    51413
    # Transmission remote connection
    9091
  ];

  networking.firewall.allowedUDPPorts = [
    # In order to enable discovery of Google Cast devices (and possibly other Spotify Connect devices) in the same network by the Spotify app, need to open UDP port 5353:
    5353
    # BitTorrent
    51413
    # Transmission remote connection
    9091
  ];

  # Fish shell
  programs.fish.enable = true;

  # Direnv - To automatically setup nix shells when entering a project directory
  programs.direnv.enable = true;

  # Enable IPv6 globally (May want to manually disable for each VPN connection, if the provider doesn't support it)
  networking.enableIPv6 = true;

  # Container virtualization functionality
  virtualisation.containers.enable = true;
  virtualisation.docker = {
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
    enable = true;
  };

  # GSConnect
  programs.kdeconnect.enable = true;
  programs.kdeconnect.package = pkgs.gnomeExtensions.gsconnect;

  # VMs
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  # security.wrappers.spice-client-glib-usb-acl-helper.source = "${pkgs.spice-gtk}/bin/spice-client-glib-usb-acl-helper";

  environment.pathsToLink = [ "/share/fish" ];

  # Set aliases across sessions
  programs.fish.shellAliases = lib.mkForce {
    gitwordschanged = ''nix-shell -p git --run "git diff --word-diff=porcelain HEAD | grep -e '^[-+][^-+]' | wc -w"'';
    gitwordsadded = ''nix-shell -p git --run "git diff --word-diff=porcelain HEAD | grep -e '^+[^-+]' | wc -w"'';
    list_profile_packages = "nix-store --query --requisites /run/current-system | cut -d- -f2- | sort -u";
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

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  #
  # No need to enable legacy support.
  # This card is newer than Southern Islands (Radeon HD 7000) series and Sea Islands (Radeon HD 8000) series cards
  # This enables use of `amdgpu` kernel driver for legacy hardware
  hardware.amdgpu.legacySupport.enable = false;

  #
  # Do not use AMDVLK drivers for Vulkan support
  # If enabled, adds the necessary packages to `hardware.graphics.extraPackages[32]`
  # See: https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/modules/services/hardware/amdvlk.nix
  hardware.amdgpu.amdvlk.enable = false;
  # ...Prefer RADV drivers, provided by Mesa

  #
  # OpenCL support using AMD ROCM runtime library
  # Adds the necessary {packages}"rocmPackages.clr{.icd}" to {config}`hardware.graphics.extraPackages`
  hardware.amdgpu.opencl.enable = true;

  #
  # Adds "amdgpu" kernel module to initrd
  # hardware.amdgpu.initrd.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # For 32 bit applications

    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      rocmPackages.clr

      # Video Accelaration library
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
    extraPackages32 = with pkgs; [ ];
  };

  environment.variables = {
    "VDPAU_DRIVER" = "radeonsi";
    "LIBVA_DRIVER_NAME" = "radeonsi";
  };

  # Force radv
  environment.variables.AMD_VULKAN_ICD = "RADV";
  # Or
  environment.variables.VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
