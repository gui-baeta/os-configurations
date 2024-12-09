{ ... }:

{
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
}
