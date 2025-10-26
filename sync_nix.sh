#!/usr/bin/env bash

NIXPKGS="/nix/var/nix/profiles/per-user/root/channels/nixos"
NIXOS_DIR="/etc/nixos/"

SOURCE="${1:-}"

# Usage: ./sync_nix.sh /path/to/nixos-tree
# Takes targeted nix tree and syncs it to your /etc/nixos/ 
# ensures owner and permissions are correct
if [ -z "$SOURCE" ]; then
    echo "Usage: $0 <destination_directory>"
    exit 1
fi

# Ensure trailing slash on SOURCE
case "$SOURCE" in
    */) ;;
    *) SOURCE="${SOURCE}/" ;;
esac


sudo rsync -a \
    --exclude 'hardware-configuration' \
    --exclude 'configuration.nix.save' \
    "$SOURCE" "$NIXOS_DIR"
sudo chown $USER:users --recursive "$NIXOS_DIR"
