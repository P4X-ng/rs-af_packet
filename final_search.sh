#!/bin/bash
echo "Searching for problematic GitHub actions..."
echo "=== github/copilot-agent references ==="
grep -r "github/copilot-agent" .github/workflows/ || echo "None found"
echo ""
echo "=== austenstone/copilot-cli-action references ==="
grep -r "austenstone/copilot-cli-action" .github/workflows/ || echo "None found"
echo ""
echo "Search complete."