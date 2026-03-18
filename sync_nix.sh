#!/usr/bin/env bash

# Usage:$ ./sync_nix.sh <targeted/tree/nixos/>
# Takes targeted nix tree and syncs it to your /etc/nixos/ 
# ensures owner and permissions are correct

set -euo pipefail  # Exit on errors, undefined vars, pipe failures


if [ ! -d "$SOURCE" ]; then
    echo "Error: Source directory does not exist: $SOURCE"
    exit 1
fi

if [ ! -d "$NIXOS_DIR" ]; then
    echo "Error: NIXOS_DIR does not exist: $NIXOS_DIR"
    exit 1
fi



NIXPKGS="/nix/var/nix/profiles/per-user/root/channels/nixos"
NIXOS_DIR="/etc/nixos"

SOURCE="${1:-}"

if [ -z "$SOURCE" ]; then
    echo "Usage: $0 <source_directory>"
    exit 1
fi

# Ensure trailing slash on SOURCE
case "$SOURCE" in
    */) ;;
    *) SOURCE="${SOURCE}/" ;;
esac

sudo cp /etc/nixos/hardware-configuration.nix "$SOURCE"
if [ -f /etc/nixos/configuration.nix.save ]; then
    sudo cp /etc/nixos/configuration.nix.save "$SOURCE"
else
    echo "Warning: /etc/nixos/configuration.nix.save not found, creating backup."
    sudo cp /etc/nixos/configuration.nix /etc/nixos/configuration.nix.save
fi

sudo rsync -a --delete \
    --exclude 'hardware-configuration' \
    --exclude 'configuration.nix.save' \
    "$SOURCE" "$NIXOS_DIR"/
sudo chown root:root -R "$NIXOS_DIR"



# Create backup BEFORE syncing
if [ ! -f "$NIXOS_DIR/configuration.nix.save" ]; then
    echo "Creating backup of configuration.nix..."
    sudo cp "$NIXOS_DIR/configuration.nix" "$NIXOS_DIR/configuration.nix.save.$(date +%Y%m%d%H%M%S)"
fi



4. Add Dry-Run Option
4. Add Dry-Run Option


DRY_RUN="${2:-false}"
if [ "$DRY_RUN" = "true" ]; then
    echo "Dry-run mode enabled - no changes will be made"
    # Add --dry-run to rsync
fi



5. Preserve Permissions Better


# Instead of forcing root:root, preserve original permissions
sudo rsync -a --delete --no-owner --no-group \
    --exclude 'hardware-configuration' \
    --exclude 'configuration.nix.save*' \
    "$SOURCE" "$NIXOS_DIR"/

