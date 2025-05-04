{
  pkgs,
  config,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-graphical-gnome.nix")
    (modulesPath + "/installer/cd-dvd/channel.nix")
    ../../modules/overrides.nix
  ];

  boot.kernelModules = [
    "amdgpu"
    "kvm-amd"
  ];
  boot.extraModulePackages = [ ];

  boot = {
    supportedFilesystems = [
      "ext4"
      "btrfs"
    ];
  };

  # Disable the GNOME3/GDM auto-suspend feature that cannot be disabled in GUI!
  # If no user is logged in, the machine will power down after 20 minutes.
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "sdhci_pci"
    "ahci"
    "nvme"
    "rtsx_pci_sdmmc"
    "sd_mod"
    "sr_mod"
    "dm-snapshot"
    "usb_storage"
    "usbhid"
    "amdgpu"
  ];

  # sops = {
  #   defaultSopsFile = ../../secrets/secrets.yaml;
  #   defaultSopsFormat = "yaml";
  #   age.keyFile = "/home/guibaeta/.config/sops/age/keys.txt";
  # };

  services.ttyd.enableIPv6 = false;

  networking.hostName = "iso-image"; # Define your hostname.
  # networking.networkmanager = {
  #   enable = true;
  #   ensureProfiles = {
  #     environmentFiles = [ config.sops.secrets."wireless.env".path ];
  #     profiles = {
  #       mobile-ap = {
  #         connection = {
  #           id = "mobile-ap";
  #           type = "wifi";
  #         };
  #         ipv4 = {
  #           method = "auto";
  #         };
  #         ipv6 = {
  #           addr-gen-mode = "default";
  #           method = "disabled";
  #         };
  #         proxy = { };
  #         wifi = {
  #           ssid = "$MOBILE_AP_WIFI_SSID";
  #         };
  #         wifi-security = {
  #           key-mgmt = "wpa-psk";
  #           psk = "$MOBILE_AP_WIFI_PASSWORD";
  #         };
  #       };
  #       home-wifi-5ghz = {
  #         proxy = { };
  #         ipv4 = {
  #           dns = "1.1.1.1;1.0.0.1;";
  #           ignore-auto-dns = "true";
  #           method = "auto";
  #         };
  #         ipv6 = {
  #           addr-gen-mode = "default";
  #           method = "disabled";
  #         };
  #         connection = {
  #           id = "home-wifi";
  #           type = "wifi";
  #         };
  #         wifi.ssid = "$HOME_WIFI_5GHZ_SSID";
  #         wifi-security = {
  #           auth-alg = "open"; # NOTE: Needed ?
  #           key-mgmt = "wpa-psk";
  #           psk = "$HOME_WIFI_5GHZ_PASSWORD";
  #         };
  #       };
  #       home-wifi = {
  #         proxy = { };
  #         ipv4 = {
  #           dns = "1.1.1.1;1.0.0.1;";
  #           ignore-auto-dns = "true";
  #           method = "auto";
  #         };
  #         ipv6 = {
  #           addr-gen-mode = "default";
  #           method = "disabled";
  #         };
  #         connection = {
  #           id = "home-wifi";
  #           type = "wifi";
  #         };
  #         wifi.ssid = "$HOME_WIFI_SSID";
  #         wifi-security = {
  #           auth-alg = "open"; # NOTE: Needed ?
  #           key-mgmt = "wpa-psk";
  #           psk = "$HOME_WIFI_PASSWORD";
  #         };
  #       };
  #     };
  #   };
  # };

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

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    videoDrivers = [ "modesetting" ];
  };
  services.displayManager.autoLogin = {
    enable = true;
    user = "nixos";
  };

  # Enable SSH in the boot process.
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];

  services.openssh.enable = true;
  users.users.nixos.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGZ6YUBLwRNsonnP4QcsHsIaX2bRdYmd4gOM16esA5uX guilherme.baeta.campos@gmail.com"
  ];

  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  # EFI booting
  isoImage.makeEfiBootable = true;
  # USB booting
  isoImage.makeUsbBootable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;

  users.users.nixos = {
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
    useDefaultShell = true;
  };

  programs.fish.enable = true;

  environment.systemPackages = [ ];
}
