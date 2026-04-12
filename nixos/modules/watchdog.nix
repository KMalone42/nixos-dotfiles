# modules/watchdog.nix
{ lib, config, pkgs, ... }:
let
  routerWatchdog = pkgs.writeShellScriptBin "router-watchdog" ''
    #!/usr/bin/env bash
    set -euo pipefail

    STATE_DIR="/var/lib/router-watchdog"
    LOCK_FILE="/var/run/router-watchdog.lock"
    LOG_TAG="router-watchdog"

    ROUTER_HOST="192.168.8.1"
    ROUTER_USER="root"
    SSH_KEY="/root/.ssh/id_ed25519"

    FAIL_THRESHOLD=3
    COOLDOWN_SECONDS=900

    DNS_A="1.1.1.1"
    DNS_B="8.8.8.8"

    mkdir -p "$STATE_DIR"

    exec 9>"$LOCK_FILE"
    if ! flock -n 9; then
        exit 0
    fi

    A_FAIL_FILE="$STATE_DIR/fail_1_1_1_1"
    B_FAIL_FILE="$STATE_DIR/fail_8_8_8_8"
    COOLDOWN_FILE="$STATE_DIR/last_restart"

    read_counter() {
        local file="$1"
        if [[ -f "$file" ]]; then
            cat "$file"
        else
            echo 0
        fi
    }

    write_counter() {
        local file="$1"
        local value="$2"
        printf '%s\n' "$value" > "$file"
    }

    log_msg() {
        logger -t "$LOG_TAG" "$1"
        echo "$1"
    }

    ping_target() {
        local target="$1"
        ping -c 2 -W 2 "$target" >/dev/null 2>&1
    }

    restart_router() {
        ssh -i "$SSH_KEY" \
            -o BatchMode=yes \
            -o ConnectTimeout=10 \
            -o StrictHostKeyChecking=yes \
            "''${ROUTER_USER}@''${ROUTER_HOST}" reboot
    }

    A_FAILS="$(read_counter "$A_FAIL_FILE")"
    B_FAILS="$(read_counter "$B_FAIL_FILE")"

    MINUTE="$(date +%M)"
    if (( 10#$MINUTE % 2 == 0 )); then
        TARGET="$DNS_A"
        TARGET_FILE="$A_FAIL_FILE"
        TARGET_FAILS="$A_FAILS"
    else
        TARGET="$DNS_B"
        TARGET_FILE="$B_FAIL_FILE"
        TARGET_FAILS="$B_FAILS"
    fi

    if ping_target "$TARGET"; then
        write_counter "$TARGET_FILE" 0
        log_msg "Ping OK for $TARGET"
    else
        TARGET_FAILS=$((TARGET_FAILS + 1))
        write_counter "$TARGET_FILE" "$TARGET_FAILS"
        log_msg "Ping FAILED for $TARGET (consecutive failures: $TARGET_FAILS)"
    fi

    A_FAILS="$(read_counter "$A_FAIL_FILE")"
    B_FAILS="$(read_counter "$B_FAIL_FILE")"

    if (( A_FAILS >= FAIL_THRESHOLD && B_FAILS >= FAIL_THRESHOLD )); then
        NOW="$(date +%s)"
        LAST_RESTART=0

        if [[ -f "$COOLDOWN_FILE" ]]; then
            LAST_RESTART="$(cat "$COOLDOWN_FILE")"
        fi

        if (( NOW - LAST_RESTART < COOLDOWN_SECONDS )); then
            log_msg "Both targets failed threshold, but cooldown active. Skipping reboot."
            exit 0
        fi

        log_msg "Both DNS targets failed threshold. Restarting router."
        if restart_router; then
            printf '%s\n' "$NOW" > "$COOLDOWN_FILE"
            write_counter "$A_FAIL_FILE" 0
            write_counter "$B_FAIL_FILE" 0
            log_msg "Router reboot command sent successfully."
        else
            log_msg "Router reboot command FAILED."
            exit 1
        fi
    fi
  '';
in
{
  environment.systemPackages = [ routerWatchdog ];

  systemd.services.router-watchdog = {
    description = "Router watchdog";
    path = with pkgs; [ bash util-linux iputils openssh coreutils inetutils ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${routerWatchdog}/bin/router-watchdog";
    };
  };

  systemd.timers.router-watchdog = {
    description = "Run router watchdog every minute";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "1min";
      Unit = "router-watchdog.service";
    };
  };
}
