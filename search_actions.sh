#!/bin/bash
cd /workspace
echo "Searching for any remaining problematic actions..."
echo ""
echo "=== Searching for github/copilot-agent ==="
find .github/workflows -name "*.yml" -o -name "*.yaml" | xargs grep -l "github/copilot-agent" 2>/dev/null || echo "None found"
echo ""
echo "=== Searching for austenstone/copilot-cli-action ==="
find .github/workflows -name "*.yml" -o -name "*.yaml" | xargs grep -l "austenstone/copilot-cli-action" 2>/dev/null || echo "None found"
echo ""
echo "=== All GitHub actions currently in use ==="
find .github/workflows -name "*.yml" -o -name "*.yaml" | xargs grep "uses:" | sed 's/.*uses: //' | sort | uniq
echo ""
echo "Search complete."