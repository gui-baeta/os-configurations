{
  userInf,
  lib,
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

  # services.gnome-keyring.enable = lib.mkForce false;

  programs.man.generateCaches = true;
  programs.fish.enable = true;
  programs.home-manager.enable = true;
}
