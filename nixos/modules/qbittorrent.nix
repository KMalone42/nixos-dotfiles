{ config, pkgs, lib, ... }:

let
  qbitUid = 994;   # pick an unused system UID
  qbitGid = 994;
in
{
  users.groups.qbittorrent = { gid = qbitGid; };
  users.users.qbittorrent = {
    isSystemUser = true;
    group = "qbittorrent";
    uid = qbitUid;
    home = "/var/lib/qbittorrent";
  };

  services.qbittorrent = {
    enable = true;
    user = "qbittorrent";
    group = "qbittorrent";
    webuiPort = 8080;
    serverConfig = {
      Preferences = {
        "Advanced\\NetworkInterface" = "tun0";
        "Advanced\\OptionalIPAddress" = "";
        "Session\\Interface" = "tun0";
        "Session\\InterfaceName" = "tun0";

        "WebUI\\Address" = "127.0.0.1";
        "WebUI\\CSRFProtection" = true;
        # Optional first-boot auth (change these!)
        # "WebUI\\Username" = "admin";
        # "WebUI\\Password_PBKDF2" = "<hashed>";  # or set via UI after first login
      };
    };
    openFirewall = false;
  };

  # Killswitch: only allow qBittorrent traffic via tun0
  networking.nftables = {
    enable = true;
    tables.filter = {
      family = "inet";
      content = ''
        chain output {
          type filter hook output priority 0; policy accept;

          oifname "lo" accept

          # qBittorrent (by UID) may egress only via tun0
          meta skuid ${toString qbitUid} oifname "tun0" accept
          meta skuid ${toString qbitUid} drop
        }
      '';
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts."qbittorrent.local" = {
      listen = [{ addr = "0.0.0.0"; port = 8090; }];
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
        proxyWebsockets = true;
      };
    };
  };

  # Only open torrent port on tun0 (replace if you use a different port)
  networking.firewall.interfaces.tun0.allowedTCPPorts = [ 51413 ];
  networking.firewall.interfaces.tun0.allowedUDPPorts = [ 51413 ];

  # Allow LAN access to nginx reverse proxy
  networking.firewall.allowedTCPPorts = [ 8090 ];
}

