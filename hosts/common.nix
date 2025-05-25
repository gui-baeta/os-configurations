{ lib, ... }:
{
  imports = [
    ./sops-configs.nix
    ./keychain-doodads.nix
    ./music.nix
    ./yubiyubi.nix
  ];

  documentation.man.generateCaches = true;

  # Fish shell
  programs.fish = {
    enable = true;
    shellAbbrs = {
      ll = "ls -la";
      hx = "hx .";
      gitstatus = "git status";
      gitstatusv = "git status -v";
      gitaddp = "git add -p";
      gitcommitm = "git commit -m";
      gitrestorep = "git restore -p";
      gitrestorestagedp = "git restore --staged -p";
    };
  };
  # Direnv - To automatically setup nix shells when entering a project directory
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
    silent = false;
    loadInNixShell = true;
    direnvrcExtra = ''
      dotenv_if_exists .env
    '';
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  environment.variables.XDG_RUNTIME_DIR = "/run/user/$UID";
  xdg.portal.enable = true;
  xdg.portal.wlr.enable = true; # Enable Screen Sharing
  services.dbus.enable = true;
  # to enable org.freedesktop.secrets.service
  services.passSecretService.enable = true;
  # services.gnome.gnome-keyring.enable = lib.mkForce false;
  # security.pam.services.gdm.enableGnomeKeyring = lib.mkForce false;

  networking.hosts = {
    "192.168.1.1" = [ "rectangular-cuboid" ];
    "192.168.1.10" = [ "light-bulb" ];
    "192.168.1.20" = [ "pen-and-paper" ];
    "192.168.1.111" = [ "iso-image" ];
    "192.168.1.99" = [ "lithium-sandwich" ];
  };
}
