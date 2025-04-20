{ pkgs, ... }:
{
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/guibaeta/.config/sops/age/keys.txt";
}
