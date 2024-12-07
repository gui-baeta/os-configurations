{ pkgs, ... }:

{
	# Bootloader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	boot.kernelPackages = pkgs.linuxPackages_latest;
	# TODO I can create a module for this
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

	boot.kernelParams = [ "amdgpu.abmlevel=0" "amdgpu.dcdebugmask=0x10" "amdgpu.dcdebugmask=0x200" ]; # "sdr" "psr" "psr"
	boot.kernelModules = [ "amdgpu" "kvm-amd" ];
	boot.extraModulePackages = [ ];
	boot.supportedFilesystems = [ "nfs" ]; # For NFS Client to work

	boot.initrd.availableKernelModules = [ "nfs" "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" "amdgpu" ];

	# TODO This should go in the hardware-configuration.nix
	boot.initrd.luks.devices."luks-fe128010-0577-4daa-8a2e-1b43503da280".device = "/dev/disk/by-uuid/fe128010-0577-4daa-8a2e-1b43503da280";
}