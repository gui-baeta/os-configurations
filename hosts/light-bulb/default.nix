{
  inputs,
  ...
}:

{
  imports = [
    #
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    #
    # Generic configs
    ./configuration.nix
    #
    # Network adapter quirks
    ./network-adapter-quirks.nix
    #
    # Graphics related quirks
    ./graphics-quirks.nix
    #
    # System Packages that don't make sense to have in all hosts
    ./host-specific-programs.nix
    #
    # Home VPN thingdadoo
    # ./home-vpn.nix
    #
    ./sops-configs.nix
  ];
}
