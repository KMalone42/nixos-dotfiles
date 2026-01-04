{ config, pkgs, lib, ... }:

let
  vpnLeakScript = ''
    #!/usr/bin/env bash
    set -euo pipefail

    # === CONFIG ===
    VPN_IF="${VPN_IF:-tun0}"
    CHECK_URLS=( "https://ifconfig.co/ip" "https://icanhazip.com" "https://ipinfo.io/ip" )
    # Cloudflare TXT whoami service used to detect which IP DNS thinks you are
    WHOAMI_DNS_NAME="whoami.cloudflare"
    LOG_DIR="${LOG_DIR:-/var/log/vpn-leak-check}"
    WEBHOOK="${WEBHOOK:-}"  # optional: call this webhook with JSON payload on leak
    ACTION_ON_LEAK="${ACTION_ON_LEAK:-none}" # none|restart-vpn|shutdown-network
    VPN_SYSTEMD_SERVICE="${VPN_SYSTEMD_SERVICE:-openvpn-client@myvpn.service}" # if using systemd-managed vpn
    TIMEOUT_CURL=8
    # ==============

    mkdir -p "$LOG_DIR"
    TS="$(date --iso-8601=seconds)"
    OUTFILE="$LOG_DIR/check-$TS.json"

    # helper: log and exit
    die() {
      echo "$1" | tee -a "$OUTFILE"
      exit 2
    }

    echo "{ \"time\": \"$TS\", \"checks\": {" > "$OUTFILE"

    # 1) interface present?
    if ip link show dev "$VPN_IF" > /dev/null 2>&1; then
      echo "\"iface_exists\": true," >> "$OUTFILE"
    else
      echo "\"iface_exists\": false" >> "$OUTFILE"
      echo "}" >> "$OUTFILE"
      echo ", \"leak\": \"vpn_interface_missing\" }" >> "$OUTFILE"
      cat "$OUTFILE"
      # optional action
      if [ "$ACTION_ON_LEAK" = "shutdown-network" ]; then
        systemctl stop systemd-networkd.socket || true
        systemctl stop systemd-networkd || true
      elif [ "$ACTION_ON_LEAK" = "restart-vpn" ]; then
        systemctl restart "$VPN_SYSTEMD_SERVICE" || true
      fi
      exit 2
    fi

    # 2) default route via VPN?
    default_line="$(ip route show default 0.0.0.0/0 | head -n1 || true)"
    if echo "$default_line" | grep -q "dev $VPN_IF"; then
      echo "\"default_route_via_vpn\": true," >> "$OUTFILE"
    else
      echo "\"default_route_via_vpn\": false," >> "$OUTFILE"
      echo "\"default_route_line\": \"$(echo "$default_line" | sed 's/"/\\"/g')\"," >> "$OUTFILE"
    fi

    # 3) get tun0 local IP (if exists)
    vpn_local_ip="$(ip -4 -o addr show dev "$VPN_IF" 2>/dev/null | awk '{print $4}' | cut -d/ -f1 || true)"
    echo "\"vpn_local_ip\": \"${vpn_local_ip}\"," >> "$OUTFILE"

    # 4) external IP checks
    echo "\"external_ip_checks\": {" >> "$OUTFILE"
    first_ip=""
    discrepancy=false
    idx=0
    for url in "${CHECK_URLS[@]}"; do
      idx=$((idx+1))
      ip=$(curl -s --max-time $TIMEOUT_CURL -4 "$url" || echo "")
      ip="$(echo "$ip" | tr -d '[:space:]')"
      echo "\"$url\": \"${ip}\"," >> "$OUTFILE"
      if [ -z "$first_ip" ]; then first_ip="$ip"; fi
      if [ -n "$ip" ] && [ "$ip" != "$first_ip" ]; then discrepancy=true; fi
    done
    # write summary
    echo "\"first_ip\": \"${first_ip}\"," >> "$OUTFILE"
    echo "\"disagreement_between_services\": ${discrepancy}" >> "$OUTFILE"
    echo "}," >> "$OUTFILE"

    # 5) DNS leak check:
    # Determine system resolver (first nameserver in /etc/resolv.conf or resolvectl)
    sys_resolver=""
    if command -v resolvectl >/dev/null 2>&1; then
      # pick first non-loopback DNS server from resolvectl
      sys_resolver="$(resolvectl status 2>/dev/null | awk '/DNS Servers:/{getline; print $1; exit}' || true)"
    fi
    if [ -z "$sys_resolver" ]; then
      sys_resolver="$(awk '/^nameserver/ {print $2; exit}' /etc/resolv.conf || true)"
    fi
    echo "\"system_resolver\": \"${sys_resolver}\"," >> "$OUTFILE"

    # Query the whoami TXT via system resolver
    dns_seen_ip_sys=""
    if [ -n "$sys_resolver" ]; then
      dns_seen_ip_sys="$(dig +short TXT ${WHOAMI_DNS_NAME} @${sys_resolver} 2>/dev/null | tr -d '"' | awk '{print $1}' || true)"
    fi
    # Query known public resolver directly
    dns_seen_ip_cloudflare="$(dig +short TXT ${WHOAMI_DNS_NAME} @1.1.1.1 2>/dev/null | tr -d '"' | awk '{print $1}' || true)"

    echo "\"dns_seen_ip_system_resolver\": \"${dns_seen_ip_sys}\"," >> "$OUTFILE"
    echo "\"dns_seen_ip_1.1.1.1\": \"${dns_seen_ip_cloudflare}\"" >> "$OUTFILE"

    # 6) decide leak heuristics
    leaked=false
    reasons=()

    # a) default route not via VPN
    if ! echo "$default_line" | grep -q "dev $VPN_IF"; then
      leaked=true
      reasons+=("default_route_not_via_${VPN_IF}")
    fi

    # b) external IP missing or blank
    if [ -z "$first_ip" ]; then
      leaked=true
      reasons+=("external_ip_unknown")
    fi

    # c) DNS resolver sees a different IP than external IP (DNS leak)
    if [ -n "$dns_seen_ip_sys" ] && [ -n "$first_ip" ] && [ "$dns_seen_ip_sys" != "$first_ip" ]; then
      leaked=true
      reasons+=("dns_leak_system_resolver_sees_${dns_seen_ip_sys}_vs_external_${first_ip}")
    fi

    # d) disagreement between public checkers
    if [ "$discrepancy" = true ]; then
      leaked=true
      reasons+=("external_ip_disagreement_between_services")
    fi

    # Output decision
    if [ "$leaked" = true ]; then
      echo "\"leak_detected\": true," >> "$OUTFILE"
      echo "\"reasons\": [\"$(printf "%s\",\"" "${reasons[@]}" | sed 's/","$//')\"]" >> "$OUTFILE"
      echo "}" >> "$OUTFILE"
      cat "$OUTFILE"
      # optional webhook and actions
      if [ -n "$WEBHOOK" ]; then
        curl -s -m 8 -X POST -H 'Content-Type: application/json' --data @"$OUTFILE" "$WEBHOOK" || true
      fi
      if [ "$ACTION_ON_LEAK" = "restart-vpn" ]; then
        systemctl restart "$VPN_SYSTEMD_SERVICE" || true
      elif [ "$ACTION_ON_LEAK" = "shutdown-network" ]; then
        systemctl stop systemd-networkd || true
      fi
      exit 3
    else
      echo "\"leak_detected\": false" >> "$OUTFILE"
      echo "}" >> "$OUTFILE"
      cat "$OUTFILE"
      exit 0
    fi
  '';
in
{
  # place the script in the system files so it exists on the target
  environment.etc."nixos/vpn-leak-check.sh".source = vpnLeakScript;
  environment.etc."nixos/vpn-leak-check.sh".mode = "0755";

  # systemd service and timer
  systemd.services.vpn-leak-check = {
    description = "VPN leak detection script";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash /etc/nixos/vpn-leak-check.sh";
      # pass environment overrides if needed
      Environment = "VPN_IF=tun0 LOG_DIR=/var/log/vpn-leak-check";
    };
  };

  systemd.timers.vpn-leak-check = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "5min";
      Persistent = true;
    };
  };

  # keep logs persistent
  systemd.tmpfiles.rules = [
    "d /var/log/vpn-leak-check 0755 root root -"
  ];

  # optional convenience: a small journalctl alias (not necessary)
  # (you can `journalctl -u vpn-leak-check` to see runs)
}

