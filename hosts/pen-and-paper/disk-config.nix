{ ... }:
{
  disko.devices = {
    disk.nvme = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt"; # Initialize the disk with a GPT partition table
        partitions = {
          ESP = {
            label = "ESP";
            priority = 1; # 1st partition
            name = "ESP"; # EFI System Partition
            type = "EF00"; # EFI Partition type. UEFI compatible, not BIOS
            size = "1000M";
            content = {
              type = "filesystem";
              format = "vfat"; # Format as FAT32 filesystem
              mountpoint = "/boot";
              mountOptions = [
                "umask=0077" # no read or write access for user `other`
                "fmask=0077"
                "dmask=0077"
              ];
            };
          };
          swap = {
            size = "24G";
            content = {
              type = "swap";
              # - "once", whole swap space is discarded at swapon invocation.
              # - "pages", asynchronous discard on freed pages,
              # - "both", both policies are activated.
              discardPolicy = "once";
            };
          };
          luks = {
            label = "nvme-luks";
            # Setup the LVM partition
            size = "100%"; # Fill up the rest of the drive with it
            content = {
              type = "luks";
              name = "crypted";
              settings = {
                allowDiscards = true;
                bypassWorkqueues = true;
                crypttabExtraOpts = [
                  "fido2-device=auto"
                  "fido2-with-client-pin=no"
                  "fido2-with-user-presence=yes" # default
                  "token-timeout=10"
                ];
              };
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [
                      "subvol=@"
                      "discard=async" # tell ssd controller freed blocks async-ly. by default, for verbosity
                      "space_cache=v2" # speeds up write performance using a b-tree data structure. by default, for verbosity
                      "compress=lzo"
                      "noatime"
                    ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "subvol=@nix"
                      "discard=async"
                      "space_cache=v2"
                      "compress=lzo"
                      "noatime"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
