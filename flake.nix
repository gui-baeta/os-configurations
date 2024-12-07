{
	description = "watarefauntan's os-configurations";

	outputs = { self, nixpkgs, nix-index-database, ... } @inputs:
	{
		nixosConfigurations = {
			# Laptop - Lenovo IdeaPad 5 Pro 14ACN6
			PenAndPaper = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				modules = [
					./nixos-configs
					./nixos-configs/pen-and-paper

					nix-index-database.nixosModules.nix-index
					{ programs.nix-index-database.comma.enable = true; }
				];

				specialArgs.flake-inputs = inputs;
			};

			# Desktop - Custom built
			light-bulb = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				modules = [
					./nixos-configs
					./nixos-configs/light-bulb

					nix-index-database.nixosModules.nix-index
					{ programs.nix-index-database.comma.enable = true; }
				];

				specialArgs.flake-inputs = inputs;
			};
		};

		# TODO Understand and rework
		checks.x86_64-linux = import ./checks {
			pkgs = nixpkgs.legacyPackages.x86_64-linux;
			lib = nixpkgs.lib;
			flake-inputs = inputs;
		};
	};

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

		nix-index-database = {
			url = "github:nix-community/nix-index-database";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		# TODO See if needed
#		nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

		# TODO Interesting! See if needed
#		nixpkgs-unfree = {
#			url = "github:numtide/nixpkgs-unfree";
#			inputs.nixpkgs.follows = "nixpkgs";
#		};

		# Generic, good-to-have-and-know, configurations for various hardware
		# Especially useful for quirky hardware and linux behavior
		nixos-hardware.url = "github:NixOS/nixos-hardware/master";

		# TODO See possible use cases
#		impermanence.url = "github:nix-community/impermanence";

		nix-gaming = {
			url = "github:fufexan/nix-gaming";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		# TODO UNUSED. Declarative disk partitioning
		disko = {
			url = "github:nix-community/disko";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		# TODO UNUSED. Declarative remote builds
		nixos-anywhere = {
			url = "github:numtide/nixos-anywhere";
			inputs = {
				nixpkgs.follows = "nixpkgs";
				disko.follows = "disko";
			};
		};
	};
}