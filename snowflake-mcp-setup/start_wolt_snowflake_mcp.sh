#!/usr/bin/env bash
set -euo pipefail

MCP_BIN="${HOME}/.local/bin/snowflake-labs-mcp"
CONFIG_FILE="${HOME}/.mcp/wolt_snowflake_prod.yaml"

if [[ ! -x "$MCP_BIN" ]]; then
  echo "snowflake-labs-mcp not found at $MCP_BIN" >&2
  echo "Run: uv tool install snowflake-labs-mcp --python 3.12 --with keyring" >&2
  exit 1
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Config file not found at $CONFIG_FILE" >&2
  exit 1
fi

exec "$MCP_BIN" --service-config-file "$CONFIG_FILE" --connection-name wolt_snowflake_prod
