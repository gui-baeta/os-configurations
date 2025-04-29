{ ... }:
{
  programs = {
    # Java - For Steam
    java.enable = true;
    gamemode.enable = true;
    gamescope.enable = true;

    steam = {
      enable = true;
      #
      # Run a GameScope driven Steam session from your display-manager
      gamescopeSession.enable = true;
      #
      # Open ports in the firewall for Steam Local Network Game Transfers.
      localNetworkGameTransfers.openFirewall = true;
      #
      # Open ports in the firewall for Steam Remote Play
      remotePlay.openFirewall = true;
      #
      # Open ports in the firewall for Source Dedicated Server
      dedicatedServer.openFirewall = true;
    };
  };

  # Steam Package overrides
  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      # NOTE Uhmmmmmm DO I want this??? :-)
      # NOTE I am using RADV, RADV is nice happy nice - good performance, from MESA, its `rad` :-)
      # I assume it is using RADV anyways
      extraProfile = ''unset VK_ICD_FILENAMES'';
      extraPkgs =
        pkgs: with pkgs; [
          xorg.libXcursor
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib
          libkrb5
          keyutils
          dxvk
        ];
    };
  };
}
