{
  pkgs,
  ...
}:

{
  environment.variables.EDITOR = "hx";

  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  # Keys and Signing
  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
      enableBrowserSocket = false;
    };
  };

  #
  # Programs that are useful on any host
  #
  #  NOTE To search for packages, we can run: `$ nix search wget`
  environment.systemPackages = with pkgs; [
    # encryption tool
    age
    ssh-to-age
    # manage secrets thingdadoo tool - `secret operations`
    sops
    #
    # to tweak gnome
    gnome-tweaks
    #
    # to edit gnome registry - kinda like windows registry
    dconf-editor
    # spotify...
    spotify
    #
    # don't like it, but very useful
    vscode
    #
    # extensions for gnome
    gnomeExtensions.clipboard-history
    gnomeExtensions.blur-my-shell
    gnomeExtensions.caffeine
    gnomeExtensions.gsconnect
    #
    # for integration with the solaar app - for Logitech devices
    gnomeExtensions.solaar-extension

    # Some missing icons
    adwaita-icon-theme
    #
    # windows compatibility shit (good shit, wine is awesome)
    #   always useful to have for when we need to run software targeting the W virus
    # Wine
    # winetricks (all versions)
    winetricks
    #
    # support both 32- and 64-bit applications
    wineWowPackages.stable
    dxvk

    #
    # container-stuff frontend - Easy to scramble up *any* Linux Distro
    # for compatibility tested images SEE: https://github.com/89luca89/distrobox/blob/main/docs/compatibility.md#containers-distros
    distrobox
    #
    # similar to Docker
    podman
    #
    # client for remote desktop-ing - gtk client for the spice protocol
    spice-gtk
    #
    # nfs... utils... tools.
    nfs-utils
    #
    # app to control amd gpu - a simpler o.s. version of AMD Adrenaline
    corectrl
    #
    # to be able to copy stuff to the clipboard - wayland clipboard connector
    wl-clipboard

    # =========================================
    #  not-so-unstable pkgs go heeeeeeeeeeeere
    # =========================================
    #
    # query LLM directly in the shell. is able to read from stdin and outputs to stdout
    unstable.smartcat
    #
    # webapp frontend to interact with LLMs
    unstable.open-webui
    #
    # handy Pen / Wacom Note Taking App
    unstable.rnote
    #
    # vkdt - experimental Photo Editing tool - weird, cool, darktable like-ish.
    #        uses Vulkan directly, pretty fast
    (pkgs.symlinkJoin {
      name = "vkdt-overlay";
      paths = [ pkgs.unstable.vkdt ];
      buildInputs = [
        pkgs.makeWrapper
        pkgs.exiftool
        pkgs.gdb
      ];
      postBuild = ''
        wrapProgram $out/bin/vkdt --prefix PATH: "${
          lib.makeBinPath [
            pkgs.exiftool
            pkgs.gdb
          ]
        }"
      '';
    })
  ];
}
