{ ... }:

{
	hardware = {
		cpu.amd.updateMicrocode = true;
		enableAllFirmware = true;
		bluetooth.enable = true;
		# TODO See if raises any problems, or not
		#enableRedistributableFirmware = true;
		opentabletdriver.enable = true;

		logitech.wireless.enable = true;
	};

	services = {
		libinput = {
			enable = true;
			touchpad.middleEmulation = false;
			mouse.middleEmulation = false;
		};
	};
}