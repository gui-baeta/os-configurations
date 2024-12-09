{ ... }:

{
  # Enable Screen Sharing
  xdg.portal.wlr.enable = true;

  # Enable RealtimeKit system service. For higher priority processes like audio.
  security.rtkit.enable = true;

  # Keys and Signing
  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
      enableBrowserSocket = false;
    };
  };
}
