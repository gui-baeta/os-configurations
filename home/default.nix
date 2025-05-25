{
  inputs,
  my-secrets,
  userInf,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  # configs for home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${userInf.nick} = {
      imports = [
        ./home.nix
      ];

      home.stateVersion = "24.11";
      home.username = userInf.nick;
      home.homeDirectory = userInf.homeDir;
    };
    extraSpecialArgs = {
      inherit my-secrets;
      inherit userInf;
    };
    sharedModules = [
      inputs.sops-nix.homeManagerModules.sops
    ];
  };
}
