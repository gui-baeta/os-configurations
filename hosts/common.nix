{ ... }:
{
  imports = [
    ./sops-configs.nix
    ./music.nix
    ./yubiyubi.nix
  ];

  documentation.man.generateCaches = true;

  # Fish shell
  programs.fish = {
    enable = true;
    shellAbbrs = {
      ll = "ls -la";
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
  networking.hosts = {
    "192.168.1.1" = [ "rectangular-cuboid" ];
    "192.168.1.10" = [ "light-bulb" ];
    "192.168.1.20" = [ "pen-and-paper" ];
    "192.168.1.111" = [ "iso-image" ];
    "192.168.1.99" = [ "lithium-sandwich" ];
  };
}
