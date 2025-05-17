{
  inputs,
  userInf,
  config,
  sops-nix,
  pkgs,
  ...
}:
{
  sops = {
    defaultSopsFile = "${inputs.my-secrets}/secrets.yaml";
    defaultSopsFormat = "yaml";
    age.keyFile = "${userInf.homeDir}/.config/sops/age/keys.txt";
    secrets = {
      "yubikey/auth-maps" = { };
    };
  };
}
