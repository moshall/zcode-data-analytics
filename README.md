# zcode-data-analytics

A [ZCode](https://z.ai) port of OpenAI's official **Codex `data-analytics`** plugin. Turns analytical questions into validated answers, KPI frameworks, metric diagnostics, dashboards, notebooks, and share-ready reports — using source-backed, reproducible analyst workflows.

This is an **independent community project**. It is not affiliated with or endorsed by OpenAI or Z.ai.

## Install (one line)

```bash
curl -fsSL https://raw.githubusercontent.com/OWNER/zcode-data-analytics/main/install.sh | bash
```

That's it. The installer writes the plugin into `~/.zcode/cli/plugins/`, registers it in the `zcode-community` marketplace, and enables it. Open a new ZCode session and the skills are active.

> Replace `OWNER` with the real GitHub owner once published.

### Requirements

- macOS (the `~/.zcode/cli` path is what the installer targets)
- ZCode installed (`~/.zcode/cli/` must exist)
- `bash`, `python3`, `curl` (all ship with macOS)

### Install from a local clone / dev mode

```bash
git clone https://github.com/OWNER/zcode-data-analytics.git
cd zcode-data-analytics
bash install.sh                 # uses ./plugin/data-analytics
# or point at any plugin dir:
bash install.sh --local /path/to/data-analytics
```

## What's included

18 analyst skills auto-triggered by their descriptions:

| Skill | Use for |
|---|---|
| `index` | Primary router for Data Analytics |
| `metric-diagnostics` | Why a key metric moved |
| `design-kpis` / `kpi-reporting` | KPI frameworks, scorecards, business reviews |
| `product-business-analysis` | Recommendation-oriented decisions |
| `market-sizing` | TAM/SAM/SOM, opportunity sizing |
| `analyze-data-quality` / `validate-data` | Data quality, methodology QA |
| `build-report` (+ 3 export sub-skills) | HTML report → Google Doc/Slides/PDF |
| `build-dashboard` | Analytical dashboards |
| `visualize-data` | Chart selection + QA |
| `jupyter-notebooks` / `spreadsheets` | Reproducible notebooks, sheets |
| `gather-business-context` / `user-context` | Durable context + onboarding |

## What was removed from the upstream Codex plugin

This port keeps the **runtime-agnostic methodology** and drops two Codex-platform-specific layers that ZCode has no equivalent for:

- **Connector layer** (`.app.json`): Snowflake/Databricks/BigQuery/Notion/Slack/etc. connector IDs are Codex-tenant-specific and not available in ZCode. Provide data via files, pasted SQL results, CSV exports, or schema descriptions instead. See [`DEPENDENCIES.MD`](plugin/data-analytics/DEPENDENCIES.MD).
- **MCP widget rendering** (`mcp/server.cjs`, React widgets, `@modelcontextprotocol/ext-apps`): the interactive chart/table/dashboard widgets depend on Codex's `ui://widget` protocol and `window.openai` globals, which ZCode does not render. Reports use static PNG charts (matplotlib/Seaborn) embedded in HTML/PDF instead.

## Usage

Skills trigger automatically — no special syntax needed. Examples:

- "Diagnose why subscription ARR moved last week." → `metric-diagnostics`
- "Build a KPI framework for the customer onboarding funnel." → `design-kpis`
- "Analyze paid retention and recommend what to investigate next." → `product-business-analysis`

You can also address the plugin directly: `@Data Analytics <request>`.

## Uninstall

```bash
bash uninstall.sh
# or from anywhere:
ZCODE_DIR=~/.zcode/cli bash uninstall.sh
```

Removes the cache dir, the marketplace entry, and the `enabledPlugins` line. Your saved user-context state under `~/.zcode/cli/plugins/data/data-analytics@zcode-community/` is left untouched.

## Upstream source & sync

Ported from [`openai/role-specific-plugins`](https://github.com/openai/role-specific-plugins) at commit `ebf5795abb95c18ee17e90bc56c83820d998eecd` (pinned in [`COMMIT_PIN.txt`](COMMIT_PIN.txt)). Upgrades are manual — see [`UPSTREAM_SYNC.md`](UPSTREAM_SYNC.md).

## License

MIT. Derived from OpenAI's `role-specific-plugins` (MIT). See [`LICENSE`](LICENSE).
