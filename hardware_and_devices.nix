{config, pkgs, lib, ... }:

{
  hardware.cpu.amd.updateMicrocode = true;                                                  
  hardware.enableRedistributableFirmware = true;

  # hardware.enableAllFirmware = true;

  hardware.bluetooth.enable = true;

  # Logitech Devices (Mouse, etc)
  hardware.logitech.wireless.enable = true;
  # Systemd Service that starts after user logins
  # systemd.user.services.solaar-service = {
	#   description = "Start Solaar on user login.";
	#   serviceConfig.PassEnvironment = "DISPLAY";
	#   script = ''
	#   solaar --window=hide
	#   '';
	#   wantedBy = [ "graphical-session.target" ]; # starts after login
	#   partOf = [ "graphical-session.target" ];
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
}