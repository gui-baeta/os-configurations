{
  inputs,
  config,
  ...
}:
# Some Yubikey configs - home-manager
{
  # home.file.".gnupg/scdaemon.conf".text = ''
  #   disable-ccid
  #   pcsc-shared
  #   reader-port Yubico Yubi
  # '';
  programs.gpg = {
    enable = true;
    scdaemonSettings = {
      #
      # disable gpg `scdaemon` in favor of `pcscd` (pcsclite package)
      # disable-ccid = true; # FROM: https://wiki.archlinux.org/title/YubiKey#gpg:_no_such_device
      pcsc-shared = true;
      #
      # TODO: Test without this. As I am *not going to use* _scdaemon_, this config probably useless
      # reader-port = "Yubico Yubi"; # FROM: https://wiki.archlinux.org/title/YubiKey#Error:_Failed_connecting_to_YubiKey_5_[OTP+FIDO+CCID]._Make_sure_the_application_have_the_required_permissions.
    };
  };
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true; # Unlocks SSH keys via YubiKey
    enableScDaemon = true; # Required for smartcard operations
    enableFishIntegration = true;
  };
}
