{
  userInf,
  my-secrets,
  config,
  ...
}:
{
  home.activation.setupEtc = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    run /run/current-system/sw/bin/systemctl start --user sops-nix
  '';

  sops = {
    defaultSopsFile = "${my-secrets}/secrets.yaml";
    defaultSopsFormat = "yaml";
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSymlinkPath = "/run/user/${builtins.toString userInf.uid}/secrets";
    defaultSecretsMountPoint = "/run/user/${builtins.toString userInf.uid}/secrets.d";
    secrets = {
      "smartcat/groq" = { };
      "smartcat/anthropic" = { };
      "smartcat/mistral" = { };
    };
  };
}
