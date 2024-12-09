{ ... }:

{
  services.rpcbind.enable = true;
  services.nfs.server.enable = true;
  systemd.mounts = [{
    type = "nfs";
    mountConfig = { Options = "noatime"; };
    what = "LightBulb:/storage/Pictures";
    where = "/mnt/NFS-Pictures";
  }];
  systemd.automounts = [{
    wantedBy = [ "multi-user.target" ];
    automountConfig = { TimeoutIdleSec = "600"; };
    where = "/mnt/NFS-Pictures";
  }];
}
