#!/bin/bash
# prod-build.sh - Production optimized build script

set -e

echo "Running production build with optimizations..."

# Set production environment
export CARGO_PROFILE_RELEASE_LTO=true
export CARGO_PROFILE_RELEASE_CODEGEN_UNITS=1
export CARGO_PROFILE_RELEASE_PANIC=abort

# Build with maximum optimizations
echo "Building with production optimizations..."
cargo build --release

# Strip debug symbols for smaller binaries
if command -v strip &> /dev/null; then
    echo "Stripping debug symbols..."
    find target/release -type f -executable -exec strip {} \; 2>/dev/null || true
fi

# Run production tests
echo "Running production test suite..."
cargo test --release

# Generate optimized documentation
echo "Generating production documentation..."
cargo doc --release --no-deps

echo "Production build completed successfully!"
echo "Optimized artifacts available in: target/release/"