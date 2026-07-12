$ErrorActionPreference = "Stop"

Write-Host "Testing Snowflake authentication for wolt_snowflake_prod..."
Write-Host "A browser window will open for Wolt SSO login."
Write-Host ""

$pythonCode = @'
import snowflake.connector

conn = snowflake.connector.connect(connection_name="wolt_snowflake_prod")
cur = conn.cursor()
cur.execute("SELECT CURRENT_USER(), CURRENT_ROLE(), CURRENT_WAREHOUSE()")
row = cur.fetchone()
print(f"User:      {row[0]}")
print(f"Role:      {row[1]}")
print(f"Warehouse: {row[2]}")
cur.close()
conn.close()
print("")
print("Your identity was confirmed. You can now enable wolt_snowflake_prod in Cursor Settings -> MCP.")
'@

$uvPython = Join-Path $env:USERPROFILE ".local\share\uv\tools\snowflake-labs-mcp\Scripts\python.exe"
if (Test-Path $uvPython) {
    & $uvPython -c $pythonCode
} else {
    python -c $pythonCode
}
