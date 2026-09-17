#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
plugin_id="$(python3 -c '
import json
import sys
from pathlib import Path

manifest = json.loads(Path(sys.argv[1]).read_text())
print(manifest["id"])
' "$project_dir/manifest.json")"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
plugin_target="$config_home/omarchy/plugins/$plugin_id"

if [[ -L "$plugin_target" ]]; then
  link_target="$(readlink -f "$plugin_target")"
  if [[ "$link_target" != "$(readlink -f "$project_dir")" ]]; then
    printf 'Refusing to remove plugin link pointing elsewhere: %s\n' "$link_target" >&2
    exit 1
  fi
  rm "$plugin_target"
elif [[ -e "$plugin_target" ]]; then
  installed_id=""
  if [[ -d "$plugin_target" ]]; then
    installed_id="$(python3 -c '
import json
import sys
from pathlib import Path

try:
    print(json.loads(Path(sys.argv[1]).read_text())["id"])
except (KeyError, OSError, TypeError, ValueError):
    pass
' "$plugin_target/manifest.json")"
  fi
  if [[ "$installed_id" != "$plugin_id" ]]; then
    printf 'Refusing to remove unrelated plugin path: %s\n' "$plugin_target" >&2
    exit 1
  fi
  rm -rf "$plugin_target"
fi

if command -v omarchy-shell >/dev/null 2>&1; then
  omarchy-shell shell rescanPlugins
fi

printf 'Removed development installation for %s.\n' "$plugin_id"
