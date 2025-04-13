{ config, ... }:

{
  imports = [
    ./helix-editor.nix
    ./mpv.nix
    ./ncspot.nix
    ./smartcat/default.nix
  ];

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";

  home.username = "guibaeta";
  home.homeDirectory = "/home/guibaeta";
}
