{
  userInf,
  inputs,
  my-secrets,
  config,
  ...
}:
{
  imports = [
    ./helix-editor.nix
    ./mpv.nix
    ./ncspot.nix
    ./smartcat/default.nix
    ./firefox.nix
    ./git.nix
    ./yubiyubi.nix
    ./sops.nix
  ];

  programs.man.generateCaches = true;
  programs.fish.enable = true;
  programs.home-manager.enable = true;

  home.stateVersion = "24.11";
  home.username = userInf.nick;
  home.homeDirectory = userInf.homeDir;
}
