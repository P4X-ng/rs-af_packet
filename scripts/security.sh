#!/bin/bash
# security.sh - Security audit script

set -e

echo "Running security audit..."

# Check for cargo-audit
if command -v cargo-audit &> /dev/null; then
    echo "Running cargo audit for known vulnerabilities..."
    cargo audit
else
    echo "WARNING: cargo-audit not found, install with: cargo install cargo-audit"
fi

# Check for cargo-deny
if command -v cargo-deny &> /dev/null; then
    echo "Running cargo deny checks..."
    cargo deny check
else
    echo "INFO: cargo-deny not found, install with: cargo install cargo-deny"
fi

# Additional security checks could go here
echo "Checking for unsafe code blocks..."
grep -r "unsafe" src/ || echo "No unsafe blocks found"

echo "Security audit completed!"