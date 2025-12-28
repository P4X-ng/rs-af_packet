#!/bin/bash
# build.sh - Core library build script

set -e

echo "Building af_packet library..."

# Check for Rust toolchain
if ! command -v cargo &> /dev/null; then
    echo "ERROR: Rust/Cargo not found. Please install Rust toolchain."
    exit 1
fi

# Check dependencies first
echo "Checking dependencies..."
if ! cargo check; then
    echo "ERROR: Dependency check failed."
    exit 1
fi

# Build with standard optimizations
echo "Running cargo build..."
if ! cargo build --release; then
    echo "ERROR: Release build failed."
    exit 1
fi

# Build examples
echo "Building examples..."
if [ -d "examples/simple" ]; then
    cd examples/simple
    if ! cargo build --release; then
        echo "ERROR: Example build failed."
        cd ../..
        exit 1
    fi
    cd ../..
else
    echo "WARNING: examples/simple directory not found."
fi

echo "Build completed successfully!"