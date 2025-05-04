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
    #
    # Generic good-to-have configurations for various hardware
    # configurations for quirky hardware and linux behavior
    # nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    solaar = {
      url = "https://flakehub.com/f/Svenum/Solaar-Flake/*.tar.gz"; # For latest stable version
      inputs.nixpkgs.follows = "nixpkgs";
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
    {
      nixosConfigurations.pen-and-paper = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          unstable-pkgs = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
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
                # SEE:
                #   - https://github.com/chris-martin/home/blob/eb12e3c02d25bb1b2b2624021bd8479996352a4c/os/flake.nix
                #   - https://github.com/chris-martin/home/blob/dc79903c93f654108ea3c05cfd779bdef72eb584/os/home/modules/packages.nix
                #   - https://www.reddit.com/r/NixOS/comments/12ewa4j/newbie_how_to_use_unstable_packages_in/
                #
                # NOTE  SEE: https://github.com/Misterio77/nix-config/blob/main/flake.nix#L119C1-L126C9
                # I can do a let before defining the outputs
                unstable-pkgs = import nixpkgs-unstable {
                  inherit system;
                  config.allowUnfree = true;
                };
                pkgs = import nixpkgs {
                  inherit system;
                  config.allowUnfree = true;
                };

                # FIXME Dont know how to use it in flake. Put in module
                #   inherit inputs;
                #   # https://github.com/TLATER/dotfiles/blob/d6dd373a4de4e0f33224883c690fa6536d57ab89/nixos-config/default.nix#L63
                #   nixos-config = config;
              };
            };
          }

        ];
      };

      nixosConfigurations.light-bulb = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          unstable-pkgs = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
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
                unstable-pkgs = import nixpkgs-unstable {
                  inherit system;
                  config.allowUnfree = true;
                };
                pkgs = import nixpkgs {
                  inherit system;
                  config.allowUnfree = true;
                };
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
