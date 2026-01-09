#!/bin/bash
# build.sh - Core library build script

set -e

echo "Building af_packet library..."

# Check for Rust toolchain
if ! command -v cargo &> /dev/null; then
    echo "ERROR: Rust/Cargo not found. Please install Rust toolchain."
    exit 1
fi

# Build with standard optimizations
echo "Running cargo build..."
cargo build --release

# Build examples
echo "Building examples..."
cd examples/simple
cargo build --release
cd ../..

echo "Build completed successfully!"