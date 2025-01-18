{
  description = "watarefauntan's os-configurations";

  inputs = {
    # NixOS official package source
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Generic, good-to-have-and-know, configurations for various hardware
    # Configurations for quirky hardware and linux behavior
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, home-manager, nix-index-database, ... }@inputs: {
    # Please replace my-nixos with your hostname
    nixosConfigurations.pen-and-paper = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        # TODO Put things from configuration.nix in modules when possible
        "${self}/modules/."
        "${self}/hosts/pen-and-paper/configuration.nix"

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.guibaeta = import "${self}/modules/home/.";

          # Optionally, use home-manager.extraSpecialArgs to pass
          # arguments to home.nix
        }

        nix-index-database.nixosModules.nix-index
        { programs.nix-index-database.comma.enable = true; }
      ];

      specialArgs = { inherit inputs; };
    };
  };
}
