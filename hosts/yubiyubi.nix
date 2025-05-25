{
  pkgs,
  config,
  lib,
  ...
}:
#
# Based on https://nixos.wiki/wiki/Yubikey
# and some healthy amount of Arch Wiki
{
  services = {
    # udev rules for yubikey
    udev.packages = [ pkgs.yubikey-personalization ];
    # to enable smartcard API thingy
    # pcscd.enable = true;
    yubikey-agent.enable = true;
  };
  environment.systemPackages = [
    pkgs.gnupg
    # doodad to manage OTPs (One-Time Passwords)
    pkgs.yubioath-flutter
    pkgs.yubikey-personalization
    pkgs.yubikey-manager
  ];
  #
  # *sudo* and *login* with Yubikey
  security.pam = {
    u2f = {
      enable = true;
      control = "sufficient";
      settings = {
        authfile = "${config.sops.secrets."yubikey/auth-maps".path}";
        # reminder message will be displayed
        cue = true;
      };
    };
    services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
    };
    # : If set, users can log in with SSH keys and PKCS#11 tokens.
    p11.enable = true; # SEE: https://github.com/OpenSC/pam_p11
  };

  # udev rules for smartcard doodads
  hardware.gpgSmartcards.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableBrowserSocket = true;
    enableSSHSupport = true;
  };

  # sops-nix will launch an scdaemon instance on boot, which will stay
  # alive and prevent the yubikey from working with any users that log
  # in later.
  # systemd.services.shutdownSopsGpg = {
  #   path = [ pkgs.gnupg ];
  #   script = ''
  #     gpgconf --homedir /var/lib/sops --kill gpg-agent
  #   '';
  #   wantedBy = [ "multi-user.target" ];
  # };
}
