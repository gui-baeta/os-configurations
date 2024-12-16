{
  description = "watarefauntan's os-configurations";

  inputs = {
    # NixOS official package source
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Generic, good-to-have-and-know, configurations for various hardware
    # Configurations for quirky hardware and linux behavior
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nix-index-database, ... }@inputs: {
    # Please replace my-nixos with your hostname
    nixosConfigurations.pen-and-paper = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./modules/.
        ./hosts/pen-and-paper/configuration.nix

        nix-index-database.nixosModules.nix-index
        { programs.nix-index-database.comma.enable = true; }
      ];

      extraSpecialArgs = {rootPath = ./.;};
      specialArgs.flake-inputs = inputs;
    };
  };
}