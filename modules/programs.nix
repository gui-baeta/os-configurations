{
  pkgs,
  unstable-pkgs,
  ...
}:

{

  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  # List packages installed in system profile.
  #  To search, run:
  #  $ nix search wget
  environment.systemPackages =
    (with pkgs; [
      (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])

      # Unofficial Amazon Games Launcher
      #nile

      # Logitech Devices GUI Manager
      solaar

      gnome-tweaks
      dconf-editor

      spotify

      vscode

      # GSConnect extensions
      gnomeExtensions.clipboard-history
      gnomeExtensions.blur-my-shell
      gnomeExtensions.caffeine
      gnomeExtensions.gsconnect

      # Some missing icons
      adwaita-icon-theme

      # Lutris
      # (lutris.override {
      #   extraLibraries =  pkgs: [
      #     # List library dependencies here
      #   ];

      #   extraPkgs = pkgs: [
      #     # List package dependencies here
      #   ];
      # })

      # Wine
      # winetricks (all versions)
      winetricks
      # support both 32- and 64-bit applications
      wineWowPackages.stable
      dxvk

      # Development
      distrobox
      podman

      # VMs
      spice-gtk

      nfs-utils

      # AMD GPU GUI
      corectrl
      wl-clipboard
    ])
    ++ (with unstable-pkgs; [
      # Unstable pkgs here
      rnote
      (pkgs.symlinkJoin {
        name = "vkdt-overlay";
        paths = [ unstable-pkgs.vkdt ];
        buildInputs = [
          pkgs.makeWrapper
          pkgs.exiftool
        ];
        postBuild = ''
          wrapProgram $out/bin/vkdt --prefix PATH: "${
            lib.makeBinPath [
              pkgs.exiftool
            ]
          }"
        '';
      })
      ansel
    ]);
}
