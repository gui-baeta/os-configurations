{config, pkgs, lib, ... }:

{
  # Enable CUPS to print documents.
  services.printing.enable = true;


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

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /storage/Pictures         pen-and-paper(rw,sync,no_subtree_check,no_root_squash)
  '';

  services.openssh = {
    enable = true;
    # require public key authentication for better security
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  # Enable the ClamAV service and keep the database up to date
  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
  };
}
