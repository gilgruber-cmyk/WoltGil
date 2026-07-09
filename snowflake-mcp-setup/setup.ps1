param(
    [Parameter(Mandatory = $true)]
    [string]$Email
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== Snowflake MCP Setup (Wolt Market) ===" -ForegroundColor Cyan
Write-Host ""

# 1. Install snowflake-labs-mcp
Write-Host "[1/5] Installing snowflake-labs-mcp..." -ForegroundColor Yellow
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "Installing uv..."
    irm https://astral.sh/uv/install.ps1 | iex
    $env:Path = "$env:USERPROFILE\.local\bin;$env:Path"
}
uv tool install snowflake-labs-mcp --python 3.12 --with keyring
Write-Host "  Installed: $env:USERPROFILE\.local\bin\snowflake-labs-mcp.exe" -ForegroundColor Green

# 2. Create directories
Write-Host "[2/5] Creating directories..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.snowflake" | Out-Null
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.mcp" | Out-Null
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.cursor" | Out-Null

# 3. Copy config files
Write-Host "[3/5] Copying configuration files..." -ForegroundColor Yellow

$connectionsToml = Get-Content (Join-Path $ScriptDir "connections.toml") -Raw -Encoding UTF8
$connectionsToml = $connectionsToml -replace "YOUR_EMAIL@wolt.com", $Email
[System.IO.File]::WriteAllText("$env:USERPROFILE\.snowflake\connections.toml", $connectionsToml, [System.Text.UTF8Encoding]::new($false))
Write-Host "  -> $env:USERPROFILE\.snowflake\connections.toml" -ForegroundColor Green

Copy-Item (Join-Path $ScriptDir "wolt_snowflake_prod.yaml") "$env:USERPROFILE\.mcp\" -Force
Write-Host "  -> $env:USERPROFILE\.mcp\wolt_snowflake_prod.yaml" -ForegroundColor Green

$startScript = Get-Content (Join-Path $ScriptDir "start_wolt_snowflake_mcp.ps1") -Raw -Encoding UTF8
[System.IO.File]::WriteAllText("$env:USERPROFILE\.mcp\start_wolt_snowflake_mcp.ps1", $startScript, [System.Text.UTF8Encoding]::new($false))
Write-Host "  -> $env:USERPROFILE\.mcp\start_wolt_snowflake_mcp.ps1" -ForegroundColor Green

$testScript = Get-Content (Join-Path $ScriptDir "test_snowflake_auth.ps1") -Raw -Encoding UTF8
[System.IO.File]::WriteAllText("$env:USERPROFILE\.mcp\test_snowflake_auth.ps1", $testScript, [System.Text.UTF8Encoding]::new($false))
Write-Host "  -> $env:USERPROFILE\.mcp\test_snowflake_auth.ps1" -ForegroundColor Green

$mcpJson = Get-Content (Join-Path $ScriptDir "mcp.json") -Raw -Encoding UTF8
$mcpJson = $mcpJson -replace "YOUR_USERNAME", $env:USERNAME
[System.IO.File]::WriteAllText("$env:USERPROFILE\.cursor\mcp.json", $mcpJson, [System.Text.UTF8Encoding]::new($false))
Write-Host "  -> $env:USERPROFILE\.cursor\mcp.json" -ForegroundColor Green

# 4. Test authentication
Write-Host ""
Write-Host "[4/5] Testing Snowflake authentication..." -ForegroundColor Yellow
Write-Host "A browser window will open for Wolt SSO login." -ForegroundColor Cyan
Write-Host ""
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.mcp\test_snowflake_auth.ps1"

# 5. Done
Write-Host ""
Write-Host "[5/5] Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Restart Cursor"
Write-Host "  2. Go to Settings -> MCP"
Write-Host "  3. Enable 'wolt_snowflake_prod'"
Write-Host "  4. Verify: green status, '1 tools, 1 resources enabled'"
Write-Host "  5. Tool available: run_snowflake_query"
Write-Host "  6. Connection: Role WOLT_MARKET, Warehouse EXPLORATION_M"
