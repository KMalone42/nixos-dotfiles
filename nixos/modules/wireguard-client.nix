# Helpful commands
# 

# modules/wireguard-client.nix
{ lib, config, pkgs, ... }:

{
  # Create wireguard dirs automatically
  systemd.tmpfiles.rules = [
    "d /etc/wireguard/                  2755 root root -" # Contains wireguard clients
    "d /etc/wireguard/mullvad/          2755 root root -" # Contains private.key + profiles
    "d /etc/wireguard/mullvad/profiles/ 2755 root root -" # Contains *.conf files
  ];

  networking.wireguard.enable = true;

  #  networking.wireguard.interfaces = {
  #    wg0 = {
  #      ips = [ "10.x.x.x/32" ]; # from Mullvad config
  #
  #      privateKeyFile = "/etc/wireguard/private.key";
  #
  #      peers = [
  #        {
  #          publicKey = "SERVER_PUBLIC_KEY";
  #          allowedIPs = [ "0.0.0.0/0" "::/0" ];
  #          endpoint = "SERVER_IP:51820";
  #          persistentKeepalive = 25;
  #        }
  #      ];
  #    };
  #
  #    networking.wg-quick.interfaces.wg0.configFile = "/etc/wireguard/wg0.conf";
  #    };
}

