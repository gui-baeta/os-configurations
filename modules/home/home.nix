{ sops-nix, config, ... }:

{
  imports = [
    ./helix-editor.nix
    ./mpv.nix
    ./ncspot.nix
    ./smartcat/default.nix
    ./firefox.nix
    ./git.nix
  ];

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";

  home.username = "guibaeta";
  home.homeDirectory = "/home/guibaeta";

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/${config.home.username}/.config/sops/age/keys.txt";
    defaultSymlinkPath = "/run/user/1000/secrets";
    defaultSecretsMountPoint = "/run/user/1000/secrets.d";
  };
}
