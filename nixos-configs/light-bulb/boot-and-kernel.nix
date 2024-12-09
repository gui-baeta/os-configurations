{ config, pkgs, lib, ... }:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "amd_iommu=pt" "iommu=soft" "pcie_aspm=off" ];
  boot.kernelModules = [ "amdgpu" "btusb" ];
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
}
