#!/bin/bash
# lint.sh - Code quality checks script

set -e

echo "Running code quality checks..."

# Check for rustfmt
if command -v rustfmt &> /dev/null; then
    echo "Checking code formatting..."
    cargo fmt -- --check
else
    echo "WARNING: rustfmt not found, skipping format check"
fi

# Check for clippy
if command -v cargo-clippy &> /dev/null; then
    echo "Running clippy lints..."
    cargo clippy --release -- -D warnings
else
    echo "WARNING: clippy not found, skipping lint check"
fi

# Check for unused dependencies
if command -v cargo-udeps &> /dev/null; then
    echo "Checking for unused dependencies..."
    cargo +nightly udeps
else
    echo "INFO: cargo-udeps not found, skipping unused dependency check"
fi

echo "Code quality checks completed!"