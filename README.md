# WoltGil

## חיבור Snowflake (Wolt Market) ל-Cursor דרך MCP

מדריך והגדרה אוטומטית לחיבור Snowflake של Wolt Market ל-Cursor IDE.

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

### קבצים שנוצרים

| קובץ | נתיב | תפקיד |
|------|------|--------|
| `connections.toml` | `~/.snowflake/` | חיבור Snowflake |
| `wolt_snowflake_prod.yaml` | `~/.mcp/` | הרשאות (read-only) |
| `mcp.json` | `~/.cursor/` | רישום MCP (ישירות ל-snowflake-labs-mcp) |
| `start_wolt_snowflake_mcp.ps1` | `~/.mcp/` | הפעלה ידנית (אופציונלי) |
| `test_snowflake_auth.ps1` | `~/.mcp/` | בדיקת login |
| `snowflake-labs-mcp.exe` | `~/.local/bin/` | בינארי |

### אימות

לאחר ההתקנה, ב-Cursor Settings → MCP:

- סטטוס ירוק: `1 tools, 1 resources enabled`
- כלי זמין: `run_snowflake_query`
- חיבור: Role `WOLT_MARKET`, Warehouse `EXPLORATION_M`

### בעיות נפוצות

| בעיה | סימן | פתרון |
|------|------|--------|
| DoorDash SSO | User is not assigned to this application | `account=doordash-wolt_market` + browser login |
| PAT invalid | Programmatic access token is invalid | `externalbrowser` — דורש PAT Network Policy |
| UTF-16 scripts | AmpersandNotAllowed | שמור scripts כ-UTF-8 ללא BOM |
| 12s timeout | login timeout ב-MCP | הסר pre-auth check |
| Cursor 30s timeout | createClient exceeded 30000ms | הרץ `test_snowflake_auth.ps1` מחוץ ל-Cursor |

### Snowflake Web

https://app.snowflake.com/doordash/wolt_market/#/homepage
