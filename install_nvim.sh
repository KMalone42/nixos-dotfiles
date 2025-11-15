#!/usr/bin/env bash

# Usage:$ ./install_nvim.sh <source/tree/nvim/>
# Takes targeted nix tree and syncs it to your ~/.config/nvim/ 
# ensures owner and permissions are correct
NVIM_DIR="$HOME/.config/nvim"
BACKUP_DIR="$HOME/.config/nvim.save"


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

# Create a backup of the existing loaded nvim
if [ -f ~/.config/nvim.save ]; then
    read -r -p "Overwrite save? (y/n): " ans
    case "$ans" in 
        [Yy]* )
            echo "Proceeding..."
            sudo cp -r ~/.config/nvim/ ~/.config/nvim.save/
            ;;
        * )
            echo "Aborted."
            ;;
    esac
else
    echo "Warning: ~/.config/nvim.save/ not found, creating backup."
    sudo cp -r ~/.config/nvim/ ~/.config/nvim.save/
fi

sudo rsync -a --delete \
    "$SOURCE" "$NVIM_DIR"/
sudo chown $USER:users -R "$NVIM_DIR"

