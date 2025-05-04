{ ... }:
{
  programs.git = {
    enable = true;
    userName = "Guilherme Fontes";
    userEmail = "48162143+gui-baeta@users.noreply.github.com";
    extraConfig = {
      # Sign commits using ssh
      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519.pub";
    };
  };
}
