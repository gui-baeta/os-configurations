{ config, pkgs, lib, ... }:

{
  # Enable the GNOME Desktop Environment.
  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;
    videoDrivers = [ "modesetting" ]; # Either this or "amdgpu-pro"

    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  # Most software has the HIP libraries hard-coded. You can work around it on NixOS by using:
  systemd.tmpfiles.rules =
    [ "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    # To enable Vulkan support for 32-bit applications (THIS ENABLES amdvlk)
    extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];

    extraPackages = [
      # Enable Video Accelaration API
      pkgs.libva
    ];
  };

  # Enable Vulkan support with amdvlk drivers
  hardware.amdgpu.amdvlk.enable = true;
  # Enable AMD OpenCL support
  hardware.amdgpu.opencl.enable = true;

  # Force radv
  environment.variables.AMD_VULKAN_ICD = "RADV";
  # Or
  environment.variables.VK_ICD_FILENAMES =
    "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";
}
