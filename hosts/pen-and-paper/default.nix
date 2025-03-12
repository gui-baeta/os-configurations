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
    # System Packages that don't make sense to have in all hosts
    ./host-specific-programs.nix
  ];

}
