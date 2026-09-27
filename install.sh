#!/usr/bin/env bash
set -euo pipefail

repo_url=${1:-https://github.com/FreyGold/frey.bar.git}
if [[ ${1:-} == --help ]]; then
  echo 'Usage: bash install.sh [git-url]'
  exit 0
fi
for program in omarchy python git hyprctl; do
  command -v "$program" >/dev/null || { echo "Missing requirement: $program" >&2; exit 1; }
done
config_dir="${HOME}/.config"
plugin_dir="$config_dir/omarchy/plugins/frey.bar"
shell_config="$config_dir/omarchy/shell.json"
hypr_config="$config_dir/hypr/hyprland.lua"
[[ -f "$hypr_config" ]] || { echo 'This installer requires Omarchy with Lua Hyprland configuration.' >&2; exit 1; }
[[ ! -e "$plugin_dir" ]] || { echo 'frey.bar is already installed. Use: omarchy plugin update frey.bar' >&2; exit 1; }
if ! python -c 'import PIL' >/dev/null 2>&1; then
  omarchy pkg add python-pillow
  python -c 'import PIL' >/dev/null
fi

mkdir -p "$config_dir/omarchy/backups"
backup_dir=$(mktemp -d "$config_dir/omarchy/backups/frey-bar.XXXXXXXX")
cp -p "$hypr_config" "$backup_dir/hyprland.lua"
if [[ -f "$shell_config" ]]; then
  cp -p "$shell_config" "$backup_dir/shell.json"
else
  touch "$backup_dir/shell-config-was-absent"
fi
echo "Configuration backup: $backup_dir"
omarchy plugin add "$repo_url" --yes
cp "$plugin_dir/restore.sh" "$backup_dir/restore.sh"

python - "$hypr_config" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
text = p.read_text()
marker = '-- frey.bar appearance integration'
if marker not in text:
    text += '''
-- frey.bar appearance integration
do
  local frey_bar_rule_path = os.getenv("HOME") .. "/.config/omarchy/plugins/frey.bar/hypr-bar.lua"
  local frey_bar_rule_file = io.open(frey_bar_rule_path, "r")
  if frey_bar_rule_file then
    frey_bar_rule_file:close()
    dofile(frey_bar_rule_path)
  end
end
'''
    p.write_text(text)
PY
hyprctl reload >/dev/null
errors=$(hyprctl configerrors)
if [[ -n "${errors//[[:space:]]/}" ]]; then
  cp -p "$backup_dir/hyprland.lua" "$hypr_config"
  hyprctl reload >/dev/null
  echo "Hyprland rejected the blur integration; original config restored: $errors" >&2
  exit 1
fi
omarchy plugin enable frey.bar
python - "$shell_config" <<'PY'
import json, os, sys, tempfile
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
bar = data.setdefault('bar', {})
for key, value in {'style': 'pill', 'opacity': 0.7, 'textColorMode': 'auto', 'widgetGap': 2}.items():
    bar.setdefault(key, value)
fd, tmp = tempfile.mkstemp(dir=p.parent, prefix='.frey-bar-config-')
with os.fdopen(fd, 'w') as out:
    json.dump(data, out, indent=2)
    out.write('\n')
os.chmod(tmp, p.stat().st_mode & 0o777)
os.replace(tmp, p)
PY
omarchy restart shell
echo 'Frey Bar installed. Right-click the bar to customize it.'
echo "Restore your previous configuration: bash '$backup_dir/restore.sh'"
