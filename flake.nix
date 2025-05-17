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
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    solaar = {
      url = "https://flakehub.com/f/Svenum/Solaar-Flake/*.tar.gz"; # For latest stable version
      inputs.nixpkgs.follows = "nixpkgs";
    };
    my-secrets = {
      url = "git+ssh://git@github.com/gui-baeta/os-configurations-secrets?ref=main";
      flake = false;
    };
    my-music = {
      url = "git+ssh://git@github.com/gui-baeta/os-configurations-music?ref=main";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nix-index-database,
      sops-nix,
      solaar,
      disko,
      ...
    }@inputs:
    let
      pkgs =
        { system }:
        let
          stablePkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          unstablePkgs = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
          finalPkgs = stablePkgs // {
            unstable = unstablePkgs;

            mpvScripts = stablePkgs.mpvScripts // {
              gradual-pause = stablePkgs.callPackage ./overlays/mpv/gradual-pause/package.nix { };
            };
          };
        in
        finalPkgs;
    in
    {
      nixosConfigurations.pen-and-paper = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          # Just use the unified package set
          # pkgs = mkPkgs { inherit system; };
          pkgs = pkgs { inherit system; };
        };
        modules = [
          ./modules/.
          ./hosts/pen-and-paper/.
          ./hosts/common.nix
          #
          # logitech devices comptblty app - solaar Flake
          solaar.nixosModules.default
          #
          # to manage disk partitioning with nix
          disko.nixosModules.disko
          #
          # manage secrets with sops through nix
          sops-nix.nixosModules.sops
          #
          # updated nix-index-database
          nix-index-database.nixosModules.nix-index
          { programs.nix-index-database.comma.enable = true; }
          #
          # configs for home-manager
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.guibaeta = {
                imports = [
                  sops-nix.homeManagerModule
                  ./modules/home/home.nix
                ];
              };

              extraSpecialArgs = {
                inherit inputs;
                pkgs = pkgs { inherit system; };
              };
            };
          }
        ];
      };

      nixosConfigurations.light-bulb = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          # Just use the unified package set
          # pkgs = mkPkgs { inherit system; };
          pkgs = pkgs { inherit system; };
        };
        modules = [
          ./modules/.
          ./hosts/light-bulb/.
          ./hosts/common.nix
          #
          # logitech devices compat. app - solaar Flake
          solaar.nixosModules.default
          #
          # secrets management with sops
          sops-nix.nixosModules.sops
          #
          # updated nix-index-database
          nix-index-database.nixosModules.nix-index
          { programs.nix-index-database.comma.enable = true; }
          #
          # configs for home-manager
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.guibaeta = {
                imports = [
                  sops-nix.homeManagerModule
                  "${self}/modules/home/home.nix"
                ];
              };

              extraSpecialArgs = {
                inherit inputs;
                pkgs = pkgs { inherit system; };
              };
            };
          }
        ];
      };
      #
      # Custom live NixOS image
      # network hostname is `iso-image` and it allows ssh-ing from light-bulb
      nixosConfigurations.iso-image = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          ./hosts/iso-image/.
          ./hosts/common.nix
          ./modules/overrides.nix
          #
          # logitech devices compat. app - solaar Flake
          solaar.nixosModules.default
          #
          # secrets management with sops
          sops-nix.nixosModules.sops
          #
          # updated nix-index-database
          nix-index-database.nixosModules.nix-index
          { programs.nix-index-database.comma.enable = true; }
        ];
      };
      #
      # : To build custom live NixOS image
      # $ nix build .#iso-image
      packages."x86_64-linux".iso-image = self.nixosConfigurations.iso-image.config.system.build.isoImage;
    };
}
