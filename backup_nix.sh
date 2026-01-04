#!/bin/sh

# Usage:$ ./backup_nvim.sh <destination>
# Check that an argument was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <destination_directory>"
    exit 1
fi

# Store the first argument
DEST="$1"

# Run rsync and chown using that argument
sudo rsync -a --delete /etc/nixos/ "$DEST"
sudo chown -R "$USER:users" "$DEST"
