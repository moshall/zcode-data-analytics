# Dependencies

## How tool references work

Data Analytics plugin files use lane placeholders such as `~~structured_data` for whatever source the user connects or provides in that category. For example, `~~structured_data` might mean a SQL runner result, API/CLI output, pasted query output, uploaded file, or schema description.

The plugin is tool-agnostic. It describes workflows in terms of analysis lanes rather than one required stack. The workflows are designed to be useful with pasted results, SQL snippets, screenshots, exports, or uploaded files.

> **ZCode port note:** Codex connector integrations (Snowflake, Databricks, BigQuery, Notion, Slack, etc.) are not available in ZCode. Provide data via files, pasted SQL results, CSV exports, or schema descriptions. The lane placeholders below map to whatever you supply.

## Dependencies for this plugin

| Category | Placeholder | Providers | Purpose |
| --- | --- | --- | --- |
| Data warehouse | `~~structured_data` | user-provided SQL results, exported CSV, schema description | Query tables, explore schemas, produce result sets |
| Notebook lab | `~~notebook_lab` | local Jupyter | Iterate, preserve reusable code, exploratory work |
| Behavior signals | `~~behavior_signals` | exported event/funnel CSV | Analyze product event trends and funnels |
| Dashboards and BI | `~~dashboards_or_bi` | dashboard metadata export, screenshot | Inspect dashboard definitions and widget SQL |
| Team communication | `~~team_communication` | pasted decision/thread excerpts | Search recent decisions, blockers, owner confirmations |
| Email context | `~~email_context` | pasted message excerpts | Inspect relevant threads and stakeholder context |
| Calendar context | `~~calendar_context` | pasted meeting notes | Check meeting timing and cadence context |
| Company docs | `~~company_docs` | pasted PRD/metric-doc text, local doc files | Read workspace knowledge and metric docs |
| Sheet workspace | `~~spreadsheet_workspace` | uploaded CSV/Sheets export | Review small exports and stakeholder tables |
| Presentation surface | `~~presentation_surface` | local Google Docs/Slides export | Create final charts and share-ready narratives |
| Code repository | `~~code_repository` | local checkout | Inspect source logic, model SQL, lineage |
| Files, notebooks, or spreadsheets | `~~files_and_notebooks` | local files, uploaded files, CSVs | Use local or uploaded analysis inputs |
| Planning tracker | `~~planning_tracker` | pasted request/owner lists | Track analysis requests and owners |
| Data operations | `~~operations_logs` | pasted pipeline/freshness notes | Check pipeline freshness and lineage |
