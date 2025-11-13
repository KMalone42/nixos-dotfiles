{ config, pkgs, lib, ... }:

{
  services.qbittorrent = {
    enable = true;
    user = "qbittorrent";
    group = "qbittorrent";
    webuiPort = 8080;  # qBittorrent’s internal WebUI port
    serverConfig = {
      Preferences = {
        # Bind WebUI only to localhost (so only nginx can reach it)
        "WebUI\\Address" = "127.0.0.1";
        "WebUI\\CSRFProtection" = true;
        # Optional: dark theme, etc.
        # "WebUI\\UseUPnP" = false;
      };
    };
    openFirewall = false;
  };

  # Expose via nginx at http://<your-host>:8090
  services.nginx = {
    enable = true;
    virtualHosts."qbittorrent.local" = {
      listen = [{ addr = "0.0.0.0"; port = 8090; }];
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
        proxyWebsockets = true;
      };
      # Add TLS or basic auth later if you like.
    };
  };

  # Allow LAN access to nginx, not qBittorrent directly
  networking.firewall.allowedTCPPorts = [ 8090 ];
}

