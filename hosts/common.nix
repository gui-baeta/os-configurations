{ config, ... }:
{
  networking.hosts = {
    "192.168.1.1" = [ "rectangular-cuboid" ];
    "192.168.1.10" = [ "light-bulb" ];
    "192.168.1.20" = [ "pen-and-paper" ];
    "192.168.1.99" = [ "lithium-sandwich" ];
  };
}
