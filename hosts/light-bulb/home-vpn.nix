{
  pkgs,
  config,
  ...
}:
let
  # generate via `openvpn --genkey secret openvpn-lightbulb-vpn-client.key`
  client-key = "/root/openvpn-lightbulb-vpn-client.key";
  domain = "127.0.0.1";
  vpn-dev = "tun0";
  port = 1194;
in
{
  services.cloudflared.enable = true;
  sops.secrets."cloudflared/cert" = {
    # Both are "cloudflared" by default
    owner = config.services.cloudflared.user;
    group = config.services.cloudflared.group;
  };

  environment.systemPackages = [
    pkgs.unstable.cloudflared
    pkgs.openvpn # for key generation
  ];

  services.cloudflared = {
    package = pkgs.unstable.cloudflared;
    tunnels = {
      "b6126611-223d-49f2-82f4-c4e042c55f6b" = {
        default = "http_status:404";
        ingress = {
          ${toString config.sops.secrets."cloudflare/domain"} = "tcp://127.0.0.1:${toString port}";
        };
        credentialsFile = config.sops.secrets."cloudflared/cert".path;
      };
    };
  };

  # sudo systemctl start nat
  networking.nat = {
    enable = true;
    # I don't think I need this since I am using cloudflared
    # externalInterface = <your-server-out-if>;
    internalInterfaces = [ vpn-dev ];
  };
  networking.firewall.trustedInterfaces = [ vpn-dev ];
  networking.firewall.allowedTCPPorts = [ port ];
  services.openvpn.servers.lightbulb-vpn.config = ''
    dev ${vpn-dev}
    proto tcp-server
    ifconfig 10.8.0.1 10.8.0.2
    secret ${client-key}
    port ${toString port}

    cipher AES-256-CBC
    auth-nocache

    comp-lzo
    keepalive 10 60
    ping-timer-rem
    persist-tun
    persist-key
  '';

  environment.etc."openvpn/lightbulb-vpn-client.ovpn" = {
    text = ''
      dev tun
      remote "${domain}"
      ifconfig 10.8.0.2 10.8.0.1

      port ${toString port}
      redirect-gateway def1

      cipher AES-256-CBC
      auth-nocache

      comp-lzo
      keepalive 10 60
      resolv-retry infinite
      nobind
      persist-key
      persist-tun
      secret [inline]

    '';
    mode = "600";
  };
  system.activationScripts.openvpn-addkey = ''
    f="/etc/openvpn/lightbulb-vpn-client.ovpn"
    if ! grep -q '<secret>' $f; then
      echo "appending secret key"
      echo "<secret>" >> $f
      cat ${client-key} >> $f
      echo "</secret>" >> $f
    fi
  '';
}
