#!/bin/bash
# docs.sh - Documentation generation script

set -e

echo "Generating documentation..."

# Generate Rust documentation
echo "Generating Rust API documentation..."
cargo doc --release --no-deps

# Create generated docs directory
mkdir -p docs/generated

# Copy generated docs
echo "Copying generated documentation..."
cp -r target/doc/* docs/generated/ 2>/dev/null || true

# Generate additional documentation if tools are available
if command -v mdbook &> /dev/null; then
    echo "Generating mdbook documentation..."
    # mdbook build would go here if we had a book.toml
fi

echo "Documentation generation completed!"
echo "API docs available in: docs/generated/"