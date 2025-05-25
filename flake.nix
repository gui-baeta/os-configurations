{
  description = "watarefauntan's os-configurations";

  inputs = {
    # NixOS official package source
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
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
      my-secrets,
      sops-nix,
      solaar,
      disko,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      userInf = {
        nick = "guibaeta";
        homeDir = "/home/${userInf.nick}";
        uid = 1000;
      };
    in
    {
      formatter.${system} = pkgs.nixfmt-rfc-style;

      # the "nixpkgs.(...)" here, ends up being the automagically inherited `pkgs` argument
      nixosConfigurations.pen-and-paper = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          inherit userInf;
          inherit my-secrets;
        };
        modules = [
          ./home/.
          ./modules/.
          ./hosts/pen-and-paper/.
          ./hosts/common.nix
          #
          # to manage disk partitioning with nix
          disko.nixosModules.disko
          #
          # logitech devices comptblty app - solaar Flake
          solaar.nixosModules.default
          #
          # manage secrets with sops through nix
          sops-nix.nixosModules.sops
          #
          # updated nix-index-database
          nix-index-database.nixosModules.nix-index
          { programs.nix-index-database.comma.enable = true; }
        ];
      };

      nixosConfigurations.light-bulb = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          inherit userInf;
          inherit my-secrets;
        };
        modules = [
          ./home/.
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
        ];
      };
      #
      # Custom live NixOS image
      # network hostname is `iso-image` and it allows ssh-ing from light-bulb
      nixosConfigurations.iso-image = nixpkgs.lib.nixosSystem {
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
      packages.${system}.iso-image = self.nixosConfigurations.iso-image.config.system.build.isoImage;
    };
}
