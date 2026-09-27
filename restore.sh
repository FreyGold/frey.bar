#!/usr/bin/env bash
set -euo pipefail
backup_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
[[ -f "$backup_dir/hyprland.lua" ]] || { echo 'Run the restore.sh inside your installation backup directory.' >&2; exit 1; }
cp -p "$backup_dir/hyprland.lua" "$HOME/.config/hypr/hyprland.lua"
if [[ -f "$backup_dir/shell.json" ]]; then
  cp -p "$backup_dir/shell.json" "$HOME/.config/omarchy/shell.json"
elif [[ -f "$backup_dir/shell-config-was-absent" ]]; then
  rm -f "$HOME/.config/omarchy/shell.json"
else
  echo 'Shell configuration backup is missing.' >&2
  exit 1
fi
hyprctl reload
hyprctl configerrors
omarchy restart shell
echo 'Restored the previous configuration. The installed plugin files remain available.'
