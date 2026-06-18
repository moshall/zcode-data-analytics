# Upstream Sync

This plugin is ported from [`openai/role-specific-plugins`](https://github.com/openai/role-specific-plugins/tree/main/plugins/data-analytics). Upstream changes frequently; this port does **not** auto-sync. Upgrades are manual and reviewed.

## Current pin

`COMMIT_PIN.txt` records the upstream commit this port is based on:

```
ebf5795abb95c18ee17e90bc56c83820d998eecd
```

## How to upgrade

1. **Get the new upstream source:**

   ```bash
   git clone https://github.com/openai/role-specific-plugins.git /tmp/rsp-upstream
   cd /tmp/rsp-upstream
   git log -1 --format='%H %ci'   # note the new commit hash
   ```

2. **Re-apply the port edits** to the new source. The full, exact edit list is documented as tasks in [`docs/superpowers/plans/2026-06-18-zcode-data-analytics-port.md`](../docs/superpowers/plans/2026-06-18-zcode-data-analytics-port.md). The non-obvious edits are:

   - **Manifest:** create `.zcode-plugin/plugin.json` (not `.codex-plugin/`); drop `apps`, `mcpServers`, `interface` fields.
   - **State paths:** replace every `$CODEX_HOME/state/plugins/{marketplace_id}/{plugin_id}/` and `$CODEX_HOME` with `~/.zcode/cli/plugins/data/data-analytics@zcode-community` across `skills/user-context/**` (markdown + JSON). In the three runtime scripts, replace `default_codex_home()` with `default_state_root()` and the `--codex-home` arg with `--state-root`. Update the validator's `USER_CONTEXT_MANDATORY_GATE_PHRASES` read-status path string to match.
   - **Connector layer:** delete `.app.json`; neutralize `load_app_connector_ids()` in `data_analytics_preflight.py` to `return {}`; guard the validator's `.app.json` block and the two `must be declared in .app.json` checks with `if app_manifest_path.exists():` / `if manifest_app_aliases:`.
   - **Widget/MCP layer:** delete `mcp/`, `src/`, `assets/`, `.mcp.json`, `package*.json`, `tsconfig.json`, `vite.config.ts`, `tests/`; delete `specifications/mcp-app-report.md` and `specifications/mcp-artifact-dashboard.md`; strip the `mcp-app` delivery mode and `analytics-app-core` references from `build-report`, `build-dashboard`, `visualize-data`, and `index`/`AGENTS.md`.

3. **Validate the port:**

   ```bash
   cd plugin/data-analytics
   python3 skills/user-context/scripts/validate_user_context_preflight.py .   # must PASS
   ```

4. **Residue sweep** (must return nothing):

   ```bash
   grep -rn "CODEX_HOME\|\.codex\b\|state/plugins/\|\.app\.json\|analytics-app-core\|mcp-app-report\|mcp-artifact-dashboard\|datascienceWidgets\|ext-apps\|window\.openai" plugin/
   ```

5. **Bump the pin and test install:**

   ```bash
   echo "<new-commit-hash>" > COMMIT_PIN.txt
   bash uninstall.sh && bash install.sh
   # open a new ZCode session; confirm skills trigger on an analytics prompt
   ```

6. **Commit and tag:**

   ```bash
   git add -A
   git commit -m "chore: sync upstream -> <new-short-hash>"
   git tag v<upstream-version-or-date>
   ```

## When NOT to sync

- If an upstream release adds a hard dependency on a Codex-only surface (a new connector, a new widget type), do not blindly port it. Evaluate whether the methodology is still usable without that surface, and document the gap in `DEPENDENCIES.MD` instead.
- The `user-context` preflight contract is enforced by `validate_user_context_preflight.py`. If upstream changes that contract, re-derive the path/connector edits from the current script rather than re-applying stale diffs.
