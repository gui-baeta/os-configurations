# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, options, ... }:

let
  office = pkgs.libreoffice-fresh-unwrapped;
in

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    
    ./applications_and_packages.nix 
    ./audio.nix 
    ./boot_and_kernel.nix
    ./display_and_graphics.nix 
    ./filesystem.nix 
    ./gnome-settings.nix 
    ./hardware_and_devices.nix 
    ./localisation.nix 
    ./networking.nix 
    ./services.nix 
    ./user.nix
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
