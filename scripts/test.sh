#!/bin/bash
# test.sh - Test suite execution script

set -e

echo "Running af_packet test suite..."

# Run unit tests
echo "Running unit tests..."
cargo test --release

# Run integration tests if they exist
if [ -d "tests" ]; then
    echo "Running integration tests..."
    cargo test --release --tests
fi

# Test examples compilation
echo "Testing examples compilation..."
cd examples/simple
cargo check
cd ../..

echo "All tests completed successfully!"