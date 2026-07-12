# WoltGil

## חיבור Snowflake (Wolt Market) ל-Cursor דרך MCP

מדריך והגדרה אוטומטית לחיבור Snowflake של Wolt Market ל-Cursor IDE.

**מדריך מלא:** [docs/SNOWFLAKE_MCP_GUIDE.md](docs/SNOWFLAKE_MCP_GUIDE.md)

### דרישות מוקדמות

| רכיב | בדיקה | הערות |
|------|--------|-------|
| uv / uvx | `where uvx` (Windows) / `which uv` (Linux) | התקנה: `irm https://astral.sh/uv/install.ps1 \| iex` |
| גישה ל-Snowflake | Web UI | התחברות דרך Wolt SSO (@wolt.com) |
| Role + Warehouse | Snowflake Web | `WOLT_MARKET` + `EXPLORATION_M` |
| Cursor | Settings → MCP | הוספת MCP server |

### התקנה מהירה (Windows)

```powershell
cd snowflake-mcp-setup
.\setup.ps1 -Email "your.name@wolt.com"
```

### התקנה מהירה (Linux/Mac)

```bash
cd snowflake-mcp-setup
chmod +x setup.sh
./setup.sh your.name@wolt.com
```

### אימות

לאחר ההתקנה, ב-Cursor Settings → MCP:

- סטטוס ירוק: `1 tools, 1 resources enabled`
- כלי זמין: `run_snowflake_query`
- חיבור: Role `WOLT_MARKET`, Warehouse `EXPLORATION_M`

### Snowflake Web

https://app.snowflake.com/doordash/wolt_market/#/homepage
