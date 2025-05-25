{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    pass-wayland
    passExtensions.pass-otp
  ];
}
