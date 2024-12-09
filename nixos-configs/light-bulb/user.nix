{ config, pkgs, lib, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.guibaeta = {
    isNormalUser = true;
    description = "Guilherme Baeta";
    extraGroups = [ "networkmanager" "wheel" "gamemode" ];
    shell = pkgs.fish;
    useDefaultShell = true;

    packages = with pkgs; [
      # Browsers
      firefox

      # Multi-purpose Calculator App
      qalculate-gtk

      # MPV but pretty
      celluloid

      stremio

      # BitTorrent client
      fragments

      # Music/Songs recognition
      mousai

      # Keepass Client
      keepassxc

      # IDEs
      jetbrains.pycharm-professional

      # Socials
      signal-desktop
      discord
      whatsapp-for-linux

      # Game Launchers
      cartridges
      prismlauncher # Minecraft Launcher

      # Office
      freeoffice
      hunspell
      hunspellDicts.uk_UA
      hunspellDicts.th_TH

      # helpful tools
      tldr
      eyedropper # Gtk based color picker

      # photo editing
      darktable

      # Pomodoro App
      gnome-solanum
    ];
  };
}
