#!/usr/bin/env bash
set -euo pipefail

ZCODE_DIR="${ZCODE_DIR:-$HOME/.zcode/cli}"
MARKETPLACE="${MARKETPLACE:-zcode-community}"
PLUGIN_NAME="${PLUGIN_NAME:-data-analytics}"

LOCAL_DIR=""
if [[ "${1:-}" == "--local" ]]; then
  LOCAL_DIR="${2:-}"
  [[ -d "$LOCAL_DIR" ]] || { echo "ERROR: --local dir not found: $LOCAL_DIR" >&2; exit 1; }
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[[ -d "$ZCODE_DIR" ]] || { echo "ERROR: $ZCODE_DIR not found. Is ZCode installed?" >&2; exit 1; }

# Resolve plugin source dir
if [[ -n "$LOCAL_DIR" ]]; then
  PLUGIN_SRC="$LOCAL_DIR"
elif [[ -d "$SCRIPT_DIR/plugin/data-analytics" ]]; then
  PLUGIN_SRC="$SCRIPT_DIR/plugin/data-analytics"
else
  echo "ERROR: plugin source not found. Run with --local <dir> or from the repo root." >&2
  exit 1
fi

[[ -f "$PLUGIN_SRC/.zcode-plugin/plugin.json" ]] || { echo "ERROR: missing .zcode-plugin/plugin.json in $PLUGIN_SRC" >&2; exit 1; }

VERSION="$(python3 -c "import json,sys; print(json.load(open(sys.argv[1]))['version'])" "$PLUGIN_SRC/.zcode-plugin/plugin.json")"
CACHE_DIR="$ZCODE_DIR/plugins/cache/$MARKETPLACE/$PLUGIN_NAME/$VERSION"

echo "Installing $PLUGIN_NAME v$VERSION -> $CACHE_DIR"
rm -rf "$CACHE_DIR"
mkdir -p "$CACHE_DIR"
# copy contents of plugin src into cache dir
cp -R "$PLUGIN_SRC/." "$CACHE_DIR/"

# Register marketplace
MKT_DIR="$ZCODE_DIR/plugins/marketplaces/$MARKETPLACE"
MKT_FILE="$MKT_DIR/marketplace.json"
mkdir -p "$MKT_DIR"
python3 - "$MKT_FILE" "$MARKETPLACE" "$PLUGIN_NAME" "$CACHE_DIR" "$VERSION" <<'PY'
import json, sys, os
mkt_file, marketplace, plugin_name, cache_dir, version = sys.argv[1:6]
if os.path.exists(mkt_file):
    data = json.load(open(mkt_file))
else:
    data = {"name": marketplace, "plugins": [], "version": 1}
data.setdefault("name", marketplace)
data.setdefault("plugins", [])
data["plugins"] = [p for p in data["plugins"] if p.get("name") != plugin_name]
data["plugins"].append({"cachePath": cache_dir, "name": plugin_name, "source": "filesystem", "version": version})
data["version"] = 1
with open(mkt_file, "w") as f:
    json.dump(data, f, indent=2)
print("registered in marketplace:", mkt_file)
PY

# Enable plugin
CFG="$ZCODE_DIR/config.json"
python3 - "$CFG" "$PLUGIN_NAME" "$MARKETPLACE" <<'PY'
import json, sys, os
cfg_file, plugin_name, marketplace = sys.argv[1:4]
key = f"{plugin_name}@{marketplace}"
if os.path.exists(cfg_file):
    cfg = json.load(open(cfg_file))
else:
    cfg = {}
cfg.setdefault("plugins", {}).setdefault("enabledPlugins", {})[key] = True
with open(cfg_file, "w") as f:
    json.dump(cfg, f, indent=2)
print("enabled in config:", key)
PY

echo
echo "Installed: $PLUGIN_NAME v$VERSION"
echo "Skills:"
python3 - "$CACHE_DIR/skills" <<'PY'
import sys, pathlib, re
root = pathlib.Path(sys.argv[1])
names = []
for f in sorted(root.glob("*/SKILL.md")):
    t = f.read_text(encoding="utf-8")
    m = re.search(r"^name:\s*(.+)$", t, re.M)
    if m: names.append(m.group(1).strip())
print("  " + "\n  ".join(names))
print(f"\n  ({len(names)} skills)")
PY
echo
echo "Uninstall: bash uninstall.sh"
echo "or:        ZCODE_DIR=$ZCODE_DIR bash uninstall.sh"
