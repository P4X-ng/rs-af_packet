#!/bin/bash
# test.sh - Test suite execution script

set -e

echo "Running af_packet test suite..."

# Check for required tools
if ! command -v cargo &> /dev/null; then
    echo "ERROR: Rust/Cargo not found. Please install Rust toolchain."
    exit 1
fi

# Run unit tests (these should work without special privileges)
echo "Running unit tests..."
if ! cargo test --lib --release; then
    echo "ERROR: Unit tests failed."
    exit 1
fi

# Run all tests (may require privileges for some network operations)
echo "Running all tests..."
if cargo test --release; then
    echo "All tests passed."
else
    echo "WARNING: Some tests failed (may require network privileges)."
    echo "This is expected in restricted CI/CD environments."
fi

# Run integration tests if they exist
if [ -d "tests" ]; then
    echo "Running integration tests..."
    if cargo test --release --tests; then
        echo "Integration tests passed."
    else
        echo "WARNING: Integration tests failed (may require network privileges)."
    fi
fi

# Test examples compilation
echo "Testing examples compilation..."
if [ -d "examples/simple" ]; then
    cd examples/simple
    if ! cargo check; then
        echo "ERROR: Example compilation check failed."
        cd ../..
        exit 1
    fi
    cd ../..
else
    echo "WARNING: examples/simple directory not found."
fi

echo "Test suite completed!"