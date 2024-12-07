{ config, pkgs, lib, flake-inputs, ... }:

{
	imports = [
	    flake-inputs.nixos-hardware.nixosModules.common-pc
	    flake-inputs.nixos-hardware.nixosModules.common-pc-ssd
	    flake-inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate

		./boot-and-kernel.nix
		./hardware-configuration.nix
		./services.nix
		./user.nix
	];

    networking.hostName = "PenAndPaper"; # Define your hostname.

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "23.11"; # Did you read the comment?
}