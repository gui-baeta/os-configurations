{
  inputs,
  sops-nix,
  pkgs,
  ...
}:
{
  sops = {
    defaultSopsFile = "${inputs.my-secrets}/secrets.yaml";
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/guibaeta/.config/sops/age/keys.txt";
  };
}
