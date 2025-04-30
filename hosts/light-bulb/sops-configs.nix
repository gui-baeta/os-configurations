{ sops-nix, pkgs, ... }:
{
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/guibaeta/.config/sops/age/keys.txt";
  };
}
