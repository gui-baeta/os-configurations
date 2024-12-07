{config, pkgs, flake-inputs, ... }:

{
	imports = [
		./audio.nix

		./display.nix
		./fonts.nix
		./for-games.nix
		./gnome.nix
		./hardware.nix
		./localisation.nix
		./networking.nix
		./package-exclusions.nix
		./programs-and-packages.nix
		./security.nix
		./services.nix
		./virtualisation.nix

		# TODO Eventually, for created modules
		# ../modules
	];

	# Necessary for opening links in gnome under certain conditions
	services.gvfs.enable = true;

	# Allow unfree packages
	nixpkgs.config = {
		allowUnfree = true;
		allowUnfreePredicate = true;
	};

	nix = {
		settings = {
			auto-optimise-store = true;
			allowUnfree = true;
			experimental-feature = [ "nix-command" "flakes" ];

			substituters = [ "https://nix-community.cachix.org" ];
			trusted-substitures = [ "https://nix-community.cachix.org" ];
			trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
		};
		# Automatic garbage collection weekly
		gc = {
			automatic = true;
			dates = "weekly";
			options = "--delete-older-than 10d";
		};

		# Make the nixpkgs flake input be used for various nix commands
		nixPath = ["nixpkgs=${flake-inputs.nixpkgs}"];
		registry.nixpkgs = {
			from = {
				id = "nixpkgs";
				type = "indirect";
			};
			flake = flake-inputs.nixpkgs;
		};
	};
}