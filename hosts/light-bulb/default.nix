{
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
  ];

}
