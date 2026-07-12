$ErrorActionPreference = "Stop"

$McpBin = Join-Path $env:USERPROFILE ".local\bin\snowflake-labs-mcp.exe"
$ConfigFile = Join-Path $env:USERPROFILE ".mcp\wolt_snowflake_prod.yaml"

if (-not (Test-Path $McpBin)) {
    Write-Error "snowflake-labs-mcp not found at $McpBin. Run: uv tool install snowflake-labs-mcp --python 3.12 --with keyring"
    exit 1
}

if (-not (Test-Path $ConfigFile)) {
    Write-Error "Config file not found at $ConfigFile"
    exit 1
}

& $McpBin --service-config-file $ConfigFile --connection-name wolt_snowflake_prod
