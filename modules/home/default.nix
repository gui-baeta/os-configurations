{ ... }:

{
  imports = [
    ./helix-editor.nix
    ./mpv.nix
  ];

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";

  home.username = "guibaeta";
  home.homeDirectory = "/home/guibaeta";
}
