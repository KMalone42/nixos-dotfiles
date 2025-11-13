#!/usr/bin/env bash

# Usage:$ ./sync_nvim.sh <targeted/tree/nvim/>
# Takes targeted nix tree and syncs it to your /etc/nixos/ 
# ensures owner and permissions are correct
NVIM_DIR="/etc/nixos/home-modules/nvim/"

SOURCE="${1:-}"

if [ -z "$SOURCE" ]; then
    echo "Usage: $0 <destination_directory>"
    exit 1
fi

# Ensure trailing slash on SOURCE
case "$SOURCE" in
    */) ;;
    *) SOURCE="${SOURCE}/" ;;
esac

# Create a backup of the existing nix tracked nvim
if [ -f /etc/nixos/home-modules/nvim.save ]; then
    read -r -p "Overwrite save? (y/n): " ans
    case "$ans" in 
        [Yy]* )
            echo "Proceeding..."
            sudo cp -r /etc/nixos/home-modules/nvim/ /etc/nixos/home-modules/nvim.save/
            ;;
        * )
            echo "Aborted."
            ;;
    esac
else
    echo "Warning: /etc/nixos/configuration.nix.save not found, creating backup."
    sudo cp /etc/nixos/home-modules/nvim/ /etc/nixos/home-modules/nvim.save/
fi

sudo rsync -a --delete \
    "$SOURCE" "$NVIM_DIR"/
sudo chown root:root -R "$NIXOS_DIR"

