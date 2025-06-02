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
  environment.pathsToLink = [ "/share/fish" ];
  programs.fish = {
    enable = true;
    shellAbbrs = {
      ll = "ls -la";
      h = "hx .";
      gitstatus = "git status";
      gitstatusv = "git status -v";
      gitaddp = "git add -p";
      gitcommitm = "git commit -m";
      gitrestorep = "git restore -p";
      gitrestorestagedp = "git restore --staged -p";
    };
    # Set aliases across sessions
    shellAliases = lib.mkForce {
      gitwordschanged = ''nix-shell -p git --run "git diff --word-diff=porcelain HEAD | grep -e '^[-+][^-+]' | wc -w"'';
      gitwordsadded = ''nix-shell -p git --run "git diff --word-diff=porcelain HEAD | grep -e '^+[^-+]' | wc -w"'';
      list_profile_packages = "nix-store --query --requisites /run/current-system | cut -d- -f2- | sort -u";
      addtopath = ''
        function addtopath
            contains -- $argv $fish_user_paths
               or set -U fish_user_paths $fish_user_paths $argv
            echo "Updated PATH: $PATH"
        end
      '';
      removefrompath = ''
        function removefrompath
            if set -l index (contains -i $argv[1] $PATH)
                set --erase --universal fish_user_paths[$index]
                echo "Updated PATH: $PATH"
            else
                echo "$argv[1] not found in PATH: $PATH"
            end
        end
      '';
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
