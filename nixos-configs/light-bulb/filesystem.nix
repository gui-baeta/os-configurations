{ config, pkgs, lib, ... }:

{
  boot.initrd.luks.reusePassphrases = true;

  # boot.initrd.luks.devices {
  #   # 256GB SSD
  #   "luks-50eaf8fa-3241-4179-b7a2-bf4af9473cee".device = "/dev/disk/by-uuid/50eaf8fa-3241-4179-b7a2-bf4af9473cee";
  # }

  fileSystems = {
    # 1TB HDD
    "/storage" = {
      device = "/dev/disk/by-uuid/8c0cdb39-bc09-417b-a662-7ae9d1220927";
      fsType = "ext4";
    };

    # # 256GB SSD
    # "/other".device = "/dev/mapper/luks-50eaf8fa-3241-4179-b7a2-bf4af9473cee";

    # # Pictures NFS Share
    # "/mnt/Pictures" = {
    #   device = "LightBulb:/Pictures";
    #   fsType = "nfs";

    #   # Lazy Mounting - Only on user access
    #   options = [ "x-systemd.automount" "noauto" ];
    # };
  };
}
