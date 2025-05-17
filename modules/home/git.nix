{ ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Guilherme Fontes";
    userEmail = "48162143+gui-baeta@users.noreply.github.com";
    # signing = {
    #   # format = "openpgp";
    #   # key = "";
    #   signByDefault = true;
    # };
    # git-worktree-switcher.enable = true;

    extraConfig = {
      # Sign commits using ssh
      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519.pub";
    };
  };
  programs.gh = {
    settings = {
      editor = "hx";
      git_protocol = "ssh";
    };
    enable = true;
  };
}
