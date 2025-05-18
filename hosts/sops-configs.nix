{
  inputs,
  my-secrets,
  userInf,
  ...
}:
{
  sops = {
    defaultSopsFile = "${inputs.my-secrets}/hosts.enc.yaml";
    defaultSopsFormat = "yaml";
    age.keyFile = "${userInf.homeDir}/.config/sops/age/keys.txt";
    secrets = {
      "yubikey/auth-maps" = { };
      "db-keyfile" = {
        sopsFile = "${inputs.my-secrets}/db-info.enc.yaml";
        key = "keyfile";
        group = "keys";
        mode = "0440";
      };
    };
  };
}
