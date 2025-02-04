{config, pkgs, lib, ... }:

{
  networking.hostName = "light-bulb"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

   # Enable IPv6 globally (May want to manually disable for each VPN connection, if the provider doesn't support it)
  networking.enableIPv6 = true;

  # Some Firewall Rules
  networking.firewall.allowedTCPPorts = [ 
    # Spotify - To sync local tracks from your filesystem with mobile devices 
    # in the same network, need to open port 57621: 
    57621 
    # For BitTorrent
    51413 

    # NFSv4
    2049
  ];

  networking.firewall.allowedUDPPorts = [ 
    # In order to enable discovery of Google Cast devices (and possibly other Spotify Connect devices) in the same network by the Spotify app, need to open UDP port 5353:
    5353 
    # BitTorrent
    51413 
  ];
}
