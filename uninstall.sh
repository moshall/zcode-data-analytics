#!/usr/bin/env bash
set -euo pipefail

ZCODE_DIR="${ZCODE_DIR:-$HOME/.zcode/cli}"
MARKETPLACE="${MARKETPLACE:-zcode-community}"
PLUGIN_NAME="${PLUGIN_NAME:-data-analytics}"

[[ -d "$ZCODE_DIR" ]] || { echo "ERROR: $ZCODE_DIR not found." >&2; exit 1; }

# Remove from config.json
CFG="$ZCODE_DIR/config.json"
if [[ -f "$CFG" ]]; then
python3 - "$CFG" "$PLUGIN_NAME" "$MARKETPLACE" <<'PY'
import json, sys, os
cfg_file, plugin_name, marketplace = sys.argv[1:4]
key = f"{plugin_name}@{marketplace}"
if os.path.exists(cfg_file):
    cfg = json.load(open(cfg_file))
    ep = cfg.get("plugins", {}).get("enabledPlugins", {})
    if key in ep:
        del ep[key]
        with open(cfg_file, "w") as f:
            json.dump(cfg, f, indent=2)
        print("removed from config:", key)
PY
fi

# Remove from marketplace.json
MKT_FILE="$ZCODE_DIR/plugins/marketplaces/$MARKETPLACE/marketplace.json"
if [[ -f "$MKT_FILE" ]]; then
python3 - "$MKT_FILE" "$PLUGIN_NAME" <<'PY'
import json, sys, os
mkt_file, plugin_name = sys.argv[1:3]
if os.path.exists(mkt_file):
    data = json.load(open(mkt_file))
    before = len(data.get("plugins", []))
    data["plugins"] = [p for p in data.get("plugins", []) if p.get("name") != plugin_name]
    if len(data["plugins"]) != before:
        with open(mkt_file, "w") as f:
            json.dump(data, f, indent=2)
        print("removed from marketplace:", plugin_name)
PY
fi

# Remove cache dir(s) for all versions
CACHE_ROOT="$ZCODE_DIR/plugins/cache/$MARKETPLACE/$PLUGIN_NAME"
if [[ -d "$CACHE_ROOT" ]]; then
  rm -rf "$CACHE_ROOT"
  echo "removed cache: $CACHE_ROOT"
fi

echo "Uninstalled $PLUGIN_NAME."
