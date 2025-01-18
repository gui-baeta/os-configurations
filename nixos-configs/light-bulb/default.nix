{ ... }:

{
  imports = [
    # TODO See if needed
    #		flake-inputs.impermanence.nixosModules.impermanence
    #		flake-inputs.disko.nixosModules.disko

    ./boot-and-kernel.nix

    ./filesystem.nix
    ./fixes.nix
    ./hardware-configuration.nix
    ./serving-of-services.nix
    ./user.nix
  ];

  networking.hostName = "light-bulb"; # Define your hostname.

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
