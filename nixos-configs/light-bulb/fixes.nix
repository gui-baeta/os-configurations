{pkgs, ... }:

{
	# Fix for Bluetooth in Intel AX200 Card to work, we need to reset it on user login
	systemd.services.usbBluetoothResetCard = {
		enable = true;
		wantedBy = [ "default.target" ];
		description = "Reset USB Bluetooth Card";
		serviceConfig = {
			Type = "oneshot";
			ExecStart = "${pkgs.usb-modeswitch}/bin/usb_modeswitch -R -v 8087 -p 0029";
		};
	};
}