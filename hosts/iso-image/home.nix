{ sops-nix, config, ... }:

{
  imports = [
    ../../modules/home/helix-editor.nix
    ../../modules/home/smartcat/default.nix
  ];

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/${config.home.username}/.config/sops/age/keys.txt";
  };
}
