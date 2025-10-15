<<<<<<< HEAD
# Dev

This is the Development branch for my personal desktop, it is updated 
automatically with `backup-nix` a script i wrote for doing exactly this.

```
#!/usr/bin/env bash
set -euo pipefail

# Paths
SRC="/etc/nixos"
DST="$HOME/Development/nixos-dotfiles/nixos"
REPO="$HOME/Development/nixos-dotfiles"

# Sync current /etc/nixos into your repo
sudo rsync -a --delete "$SRC/" "$DST/"

# Commit and push
cd "$REPO"
git checkout dev || git checkout -b dev
git add .
git commit -m "Auto backup: $(date '+%Y-%m-%d %H:%M:%S')" || echo "No changes to commit"
git push origin dev

sudo nixos-rebuild switch
```

as you can see it is fairly basic but it gets the job done.
=======
# Main

this is the main branch of my nix desktop configuration. It is updated when i
feel a major change has been made.

last update 2025-10-03

## Recent Updates
setup home-manager to track
* hypr config files
* waybar
* tmux.conf

## Todo
home-manager
* setup nvim tracking
* declare more kde apps
* get nvidia gtx 1080 working drivers
>>>>>>> be05c55 (readme added)
