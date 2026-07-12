#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 YOUR_EMAIL@wolt.com"
  exit 1
fi

EMAIL="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Snowflake MCP Setup (Wolt Market) ==="
echo ""

# 1. Install snowflake-labs-mcp
echo "[1/5] Installing snowflake-labs-mcp..."
if ! command -v uv &>/dev/null; then
  echo "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  source "$HOME/.local/bin/env"
fi
uv tool install snowflake-labs-mcp --python 3.12 --with keyring
echo "  Installed: $HOME/.local/bin/snowflake-labs-mcp"

# 2. Create directories
echo "[2/5] Creating directories..."
mkdir -p "$HOME/.snowflake" "$HOME/.mcp" "$HOME/.cursor"

# 3. Copy config files
echo "[3/5] Copying configuration files..."

sed "s/YOUR_EMAIL@wolt.com/$EMAIL/" "$SCRIPT_DIR/connections.toml" > "$HOME/.snowflake/connections.toml"
chmod 600 "$HOME/.snowflake/connections.toml"
echo "  -> $HOME/.snowflake/connections.toml"

cp "$SCRIPT_DIR/wolt_snowflake_prod.yaml" "$HOME/.mcp/"
echo "  -> $HOME/.mcp/wolt_snowflake_prod.yaml"

cp "$SCRIPT_DIR/start_wolt_snowflake_mcp.sh" "$HOME/.mcp/"
chmod +x "$HOME/.mcp/start_wolt_snowflake_mcp.sh"
echo "  -> $HOME/.mcp/start_wolt_snowflake_mcp.sh"

cp "$SCRIPT_DIR/test_snowflake_auth.sh" "$HOME/.mcp/"
chmod +x "$HOME/.mcp/test_snowflake_auth.sh"
echo "  -> $HOME/.mcp/test_snowflake_auth.sh"

cp "$SCRIPT_DIR/mcp.linux.json" "$HOME/.cursor/mcp.json"
# Replace default ubuntu home with actual $HOME
sed -i "s|/home/ubuntu|$HOME|g" "$HOME/.cursor/mcp.json"
echo "  -> $HOME/.cursor/mcp.json"

# 4. Test authentication
echo ""
echo "[4/5] Testing Snowflake authentication..."
echo "A browser window will open for Wolt SSO login."
echo ""
bash "$HOME/.mcp/test_snowflake_auth.sh"

# 5. Done
echo ""
echo "[5/5] Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Restart Cursor"
echo "  2. Go to Settings -> MCP"
echo "  3. Enable 'wolt_snowflake_prod'"
echo "  4. Verify: green status, '1 tools, 1 resources enabled'"
echo "  5. Tool available: run_snowflake_query"
echo "  6. Connection: Role WOLT_MARKET, Warehouse EXPLORATION_M"
