{ pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-graphical-gnome.nix") ];

  boot.kernelModules = [
    "amdgpu"
    "kvm-amd"
  ];
  boot.extraModulePackages = [ ];

  boot = {
    supportedFilesystems = [ "ext4" ];
  };

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "amdgpu"
  ];

  networking.hostName = "iso-image"; # Define your hostname.

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

  # Enable SSH in the boot process.
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILKAU5lq//NVCZ7pNvCmDppdWuqqN7ctFFm3a6PasNzt guibaeta@nixos"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGZ6YUBLwRNsonnP4QcsHsIaX2bRdYmd4gOM16esA5uX guilherme.baeta.campos@gmail.com"
  ];

  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  users.groups.guibaeta = { };
  users.users.guibaeta = {
    uid = 1000;
    isSystemUser = true;
    description = "Guilherme Fontes";
    group = "guibaeta";
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
