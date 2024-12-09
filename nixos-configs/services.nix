{ config, pkgs, lib, ... }:

{
  # Enable CUPS to print documents.
  services = {
    printing.enable = true;
    fwupd.enable = true;
    fstrim.enable = true;
  };
}
