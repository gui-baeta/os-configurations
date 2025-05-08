{
  lib,
  ...
}:

{
  imports = [
    #
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    #
    # Generic configs
    ./configuration.nix
    #
    # System Packages that don't make sense to have in all hosts
    ./host-specific-programs.nix

    ./disk-config.nix
  ];

  # btrfs mountOptions already define "discard=async"
  services.fstrim.enable = true; # Enabled by default
}
