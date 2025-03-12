{ pkgs, unstable-pkgs, ... }:
{
  environment.systemPackages =
    (with pkgs; [ ])
    ++ (with unstable-pkgs; [
      #
      # remote desktop client
      vmware-horizon-client
    ]);
}
