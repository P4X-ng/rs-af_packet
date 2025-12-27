#!/bin/bash
# clean.sh - Cleanup build artifacts script

set -e

echo "Cleaning build artifacts..."

# Clean main project
echo "Cleaning main project..."
cargo clean

# Clean examples
echo "Cleaning examples..."
cd examples/simple
cargo clean
cd ../..

# Clean any additional build artifacts
echo "Cleaning additional artifacts..."
rm -rf target/
rm -rf examples/simple/target/

# Clean documentation artifacts
rm -rf docs/generated/

echo "Cleanup completed successfully!"