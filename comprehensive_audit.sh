#!/bin/bash
echo "=== Comprehensive GitHub Actions Audit ==="
echo ""
echo "1. Searching for problematic github/copilot-agent references:"
grep -r "github/copilot-agent" .github/workflows/ 2>/dev/null || echo "   ✅ No github/copilot-agent references found"
echo ""

echo "2. Searching for problematic austenstone/copilot-cli-action references:"
grep -r "austenstone/copilot-cli-action" .github/workflows/ 2>/dev/null || echo "   ✅ No austenstone/copilot-cli-action references found"
echo ""

echo "3. Complete inventory of all GitHub actions in use:"
echo "   Actions found in workflows:"
grep -r "uses:" .github/workflows/ | sed 's/.*uses: /   - /' | sort | uniq
echo ""

echo "4. Checking for any 'uses:' lines that might contain problematic patterns:"
echo "   Scanning for any suspicious action references..."
grep -r "uses:.*copilot" .github/workflows/ 2>/dev/null || echo "   ✅ No copilot-related actions found"
echo ""

echo "5. Verifying workflow file syntax:"
for file in .github/workflows/*.yml .github/workflows/*.yaml; do
    if [ -f "$file" ]; then
        echo "   Checking $file..."
        # Basic YAML syntax check - look for common issues
        if grep -q "uses: github/copilot-agent" "$file"; then
            echo "   ❌ FOUND PROBLEMATIC ACTION in $file"
        elif grep -q "austenstone/copilot-cli-action" "$file"; then
            echo "   ❌ FOUND PROBLEMATIC ACTION in $file"
        else
            echo "   ✅ $file appears clean"
        fi
    fi
done
echo ""

echo "=== Audit Complete ==="