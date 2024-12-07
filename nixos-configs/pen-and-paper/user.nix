{ pkgs, ... }:
{
	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.guibaeta = {
		isNormalUser = true;
		description = "Guilherme Fontes";
		extraGroups = [ "networkmanager" "wheel" ];
		shell = pkgs.fish;
		useDefaultShell = true;

		packages = with pkgs; [
		  # Management Tools
		  git

		  # Browsers
		  (
		    pkgs.symlinkJoin {
		      name = "firefox-overlay";
		      paths = [ pkgs.firefox ];
		      buildInputs = [ pkgs.makeWrapper ];
		      postBuild = ''
		        wrapProgram $out/bin/firefox --set GTK_IM_MODULE xim
		      '';
		    }
		  )
		  google-chrome
		  brave

		  # Note Taking
		  obsidian

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

		  # Meeting Apps
		  zoom-us

		  # Game Launchers
		  cartridges
		  prismlauncher # Minecraft Launcher

		  # Office
		  freeoffice
		  hunspell
		  hunspellDicts.uk_UA
		  hunspellDicts.th_TH
		  onlyoffice-bin

		  # helpful tools
		  tldr
		  eyedropper # Gtk based color picker

		  # photo editing
		  darktable

		  # E-Reader
		  foliate

		  # Markdown editor
		  apostrophe

		  # photo editing
		  darktable

		  # Pomodoro App
		  gnome-solanum

		  # Audio Simple Wiring Tool
		  helvum

		  # Virtual Desktop Infrastructure Client
		  # vmware-horizon-client
		];
	};
}
