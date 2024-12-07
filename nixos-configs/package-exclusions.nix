{ pkgs, ... }:

{
	# Exclude unwanted default packages
	services.xserver.excludePackages = [ pkgs.xterm ];

	environment.gnome.excludePackages = (with pkgs; [
	      gnome-tour
	      snapshot
	    ]) ++ (with pkgs; [
	      seahorse # password manager
	      totem # video player
	      gnome-maps
	      gnome-music
	      epiphany # web browser
	      geary # email reader
	      gnome-contacts
	    ]);
}