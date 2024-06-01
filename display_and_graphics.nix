{config, pkgs, lib, ... }:

{
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "modesetting" ]; # Either this or "amdgpu-pro"

  # Enable Screen Sharing
  xdg.portal.wlr.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable OpenGL and Vulkan
  hardware.opengl = {
    # Mesa
    enable = true;

    # Vulkan
    driSupport = true;
 
    # Enables support for 32bit libs that steam uses
    driSupport32Bit = true; 

    extraPackages = [
      # Enable AMD OpenCL support
      pkgs.rocmPackages.clr.icd 
      
      # Enable Vulkan support with amdvlk drivers
      pkgs.amdvlk

      # Enable Video Accelaration API
      pkgs.libva 
    ];

    # To enable Vulkan support for 32-bit applications (THIS ENABLES amdvlk)
    extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
  };

  # Force radv
  environment.variables.AMD_VULKAN_ICD = "RADV";
  # Or
  environment.variables.VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";

  # Most software has the HIP libraries hard-coded. You can work around it on NixOS by using:
  systemd.tmpfiles.rules =
    [ "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}" ];
}