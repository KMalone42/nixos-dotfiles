#!/usr/bin/env bash
set -euo pipefail

# Usage:$ ./backup_nvim.sh <destination>
# Check that an argument was provided

if [ -z "$1" ]; then
    echo "Usage: $0 <destination_directory>"
    exit 1
fi
DEST="$1"


# Run `sudo nixos-rebuild switch` and eval
if sudo nixos-rebuild switch; then

    # Run rsync and chown using that argument
    sudo rsync -a --delete /etc/nixos/ "$DEST"
    sudo chown -R "$USER:users" "$DEST"

    echo "Rebuild succeeded, committing config..."

    git add .

    # Only commit if there are actual changes
    if ! git diff --cached --quiet; then
        git commit -m "nixos: backup after successful rebuild $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Backup commit created."
    else
        echo "No changes to commit."
    fi
else
    echo "Rebuild failed, not committing."
    exit 1
fi
