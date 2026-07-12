# מדריך מלא: חיבור Snowflake (Wolt Market) ל-Cursor דרך MCP

מסמך זה מתאר את כל מה שבוצע, הבעיות שנתקלנו בהן, והפתרונות — כדי שתוכל להסביר לאחרים.

## 1. מה רצינו להשיג

חיבור Cursor IDE ל-Snowflake של Wolt Market (`doordash/wolt_market`) דרך MCP Server, כדי שה-AI ב-Cursor יוכל להריץ שאילתות SQL ישירות על הנתונים.

**URL של Snowflake Web:**  
https://app.snowflake.com/doordash/wolt_market/#/homepage

## 2. דרישות מוקדמות (Prerequisites)

| רכיב | איך בודקים | הערות |
|------|------------|-------|
| uv / uvx | `where uvx` ב-PowerShell / `which uv` ב-Linux | התקנה: `irm https://astral.sh/uv/install.ps1 \| iex` |
| גישה ל-Snowflake | כניסה ל-Web UI | חשבון Wolt SSO (`@wolt.com`) |
| Role + Warehouse | ב-Snowflake Web | `WOLT_MARKET`, `EXPLORATION_M` |
| Cursor | Settings → MCP | גרסה עם תמיכה ב-MCP |

## 3. הקבצים שנוצרו / עודכנו

### קובץ 1: `connections.toml`

**נתיב:** `~/.snowflake/connections.toml` (Windows: `C:\Users\<username>\.snowflake\connections.toml`)

```toml
[wolt_snowflake_prod]
account = "doordash-wolt_market"
user = "<email>@wolt.com"
authenticator = "externalbrowser"
role = "WOLT_MARKET"
warehouse = "EXPLORATION_M"
client_store_temporary_credential = true
oauth_enable_refresh_token = true
platform_detection_timeout_seconds = 0
```

- `account = doordash-wolt_market` תואם ל-URL של Snowflake Web
- `authenticator = externalbrowser` — אימות דרך דפדפן
- `client_store_temporary_credential = true` — שמירת session ב-Credential Manager
- שם הסקשן חייב להתאים ל-`connection-name` ב-MCP

### קובץ 2: `wolt_snowflake_prod.yaml`

**נתיב:** `~/.mcp/wolt_snowflake_prod.yaml`

הרשאות read-only: Select, Describe, Use בלבד.

### קובץ 3: `mcp.json`

**נתיב:** `~/.cursor/mcp.json`

הגישה המומלצת (ישירות לבינארי):

```json
{
  "mcpServers": {
    "wolt_snowflake_prod": {
      "command": "C:\\Users\\<username>\\.local\\bin\\snowflake-labs-mcp.exe",
      "args": [
        "--service-config-file",
        "C:\\Users\\<username>\\.mcp\\wolt_snowflake_prod.yaml",
        "--connection-name",
        "wolt_snowflake_prod"
      ]
    }
  }
}
```

> **הערה:** גישה חלופית (ישנה) היא הפעלה דרך PowerShell wrapper (`start_wolt_snowflake_mcp.ps1`). הגישה הישירה פשוטה ואמינה יותר.

### קובץ 4: `start_wolt_snowflake_mcp.ps1` / `start_wolt_snowflake_mcp.sh`

**נתיב:** `~/.mcp/`

סקריפט הפעלה ידנית (אופציונלי — לבדיקות מחוץ ל-Cursor).

### קובץ 5: `test_snowflake_auth.ps1` / `test_snowflake_auth.sh`

סקריפט login חד-פעמי מחוץ ל-Cursor.

## 4. התקנת snowflake-labs-mcp

```bash
uv tool install snowflake-labs-mcp --python 3.12 --with keyring
```

**בינארי:** `~/.local/bin/snowflake-labs-mcp` (Windows: `snowflake-labs-mcp.exe`)

## 5. בעיות ופתרונות

| בעיה | תסמין | פתרון |
|------|-------|-------|
| uvx Access Denied | שגיאת הרשאות ב-temp | `uv tool install` במקום `uvx` |
| DoorDash SSO error | User is not assigned to this application | `account=doordash-wolt_market` + browser login |
| PAT invalid | Programmatic access token is invalid | חזרה ל-`externalbrowser` — PAT דורש Network Policy |
| UTF-16 scripts | AmpersandNotAllowed | כתיבה מחדש ב-UTF-8 ללא BOM |
| 12s timeout | MCP אדום למרות login | הסרת pre-auth check |
| Cursor 30s timeout | createClient exceeded 30000ms | login מחוץ ל-Cursor עם `test_snowflake_auth.ps1` |

## 6. תהליך התקנה

### התקנה אוטומטית (מומלץ)

**Windows:**

```powershell
cd snowflake-mcp-setup
.\setup.ps1 -Email "your.name@wolt.com"
```

**Linux/Mac:**

```bash
cd snowflake-mcp-setup
chmod +x setup.sh
./setup.sh your.name@wolt.com
```

### התקנה ידנית

1. התקנת uv ו-snowflake-labs-mcp
2. יצירת כל קבצי ההגדרה (ראו סעיף 3)
3. הרצת בדיקת אימות:
   - Windows: `powershell -NoExit -ExecutionPolicy Bypass -File ~/.mcp/test_snowflake_auth.ps1`
   - Linux: `bash ~/.mcp/test_snowflake_auth.sh`
4. הודעת הצלחה בדפדפן: *Your identity was confirmed...*
5. Toggle `wolt_snowflake_prod` ב-Cursor Settings → MCP

## 7. אימות

| בדיקה | תוצאה |
|-------|--------|
| MCP ב-Cursor | ירוק, `1 tools, 1 resources enabled` |
| כלי זמין | `run_snowflake_query` |
| חיבור | Role `WOLT_MARKET`, Warehouse `EXPLORATION_M` |

## 8. תחזוקה

- אם MCP אדום — הרץ שוב `test_snowflake_auth.ps1` (או `.sh` ב-Linux)
- אין צורך ב-MCP חדש — `wolt_snowflake_prod` הוא החיבור ל-Wolt Market
- PAT דורש Network Policy מ-IT

## 9. סיכום קבצים

| קובץ | נתיב | תפקיד |
|------|------|--------|
| `connections.toml` | `~/.snowflake/` | חיבור Snowflake |
| `wolt_snowflake_prod.yaml` | `~/.mcp/` | הרשאות |
| `mcp.json` | `~/.cursor/` | רישום MCP |
| `start_wolt_snowflake_mcp.ps1` | `~/.mcp/` | הפעלה (אופציונלי) |
| `test_snowflake_auth.ps1` | `~/.mcp/` | login |
| `snowflake-labs-mcp` | `~/.local/bin/` | בינארי |

## 10. מבנה הריפו

```
snowflake-mcp-setup/
├── connections.toml          # תבנית חיבור Snowflake
├── wolt_snowflake_prod.yaml  # הרשאות read-only
├── mcp.json                  # תצורת MCP ל-Windows
├── mcp.linux.json            # תצורת MCP ל-Linux/Mac
├── setup.ps1                 # התקנה אוטומטית (Windows)
├── setup.sh                  # התקנה אוטומטית (Linux/Mac)
├── start_wolt_snowflake_mcp.ps1
├── start_wolt_snowflake_mcp.sh
├── test_snowflake_auth.ps1
└── test_snowflake_auth.sh
```
