{config, pkgs, lib, ... }:

{
  # See this for further reading and improvements: https://hoverbear.org/blog/declarative-gnome-configuration-in-nixos/
  # services.xserver.desktopManager.gnome = {
  #   extraGSettingsOverrides = ''
  #     # Favorite apps in gnome-shell
  #     [org.gnome.shell]
  #     favorite-apps=['firefox.desktop', 'org.gnome.Nautilus.desktop', 'spotify.desktop']

  #     [org.gnome.desktop.wm.preferences]
  #     resize-with-right-button=true
  #     mouse-button-modifier='<Super>'
  #   '';

  #   extraGSettingsOverridePackages = [
  #     pkgs.gnome.gnome-shell # for org.gnome.shell
  #   ];
  # };
  
}