#!/bin/bash
# validate-build.sh - Comprehensive build validation script

set -e

echo "=== Comprehensive Build Validation ==="
echo "Date: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
echo "Repository: P4X-ng/rs-af_packet"
echo

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo "✅ $2"
    else
        echo "❌ $2"
        return 1
    fi
}

# Check prerequisites
echo "--- Checking Prerequisites ---"
command_exists cargo && print_status 0 "Cargo found" || print_status 1 "Cargo not found"
command_exists rustc && print_status 0 "Rust compiler found" || print_status 1 "Rust compiler not found"

# Check Rust version
RUST_VERSION=$(rustc --version 2>/dev/null || echo "unknown")
echo "Rust version: $RUST_VERSION"
echo

# Validate Cargo.toml files
echo "--- Validating Cargo.toml Files ---"
if cargo metadata --format-version 1 >/dev/null 2>&1; then
    print_status 0 "Main Cargo.toml is valid"
else
    print_status 1 "Main Cargo.toml has issues"
fi

if [ -f "examples/simple/Cargo.toml" ]; then
    cd examples/simple
    if cargo metadata --format-version 1 >/dev/null 2>&1; then
        print_status 0 "Example Cargo.toml is valid"
    else
        print_status 1 "Example Cargo.toml has issues"
    fi
    cd ../..
fi
echo

# Check dependencies
echo "--- Checking Dependencies ---"
echo "Resolving dependencies..."
if cargo tree >/dev/null 2>&1; then
    print_status 0 "Dependency resolution successful"
else
    print_status 1 "Dependency resolution failed"
fi
echo

# Build main library
echo "--- Building Main Library ---"
echo "Running cargo check..."
if cargo check 2>&1; then
    print_status 0 "Cargo check passed"
else
    print_status 1 "Cargo check failed"
fi

echo "Running cargo build..."
if cargo build 2>&1; then
    print_status 0 "Debug build successful"
else
    print_status 1 "Debug build failed"
fi

echo "Running cargo build --release..."
if cargo build --release 2>&1; then
    print_status 0 "Release build successful"
else
    print_status 1 "Release build failed"
fi
echo

# Build examples
echo "--- Building Examples ---"
if [ -d "examples/simple" ]; then
    cd examples/simple
    echo "Building simple example..."
    if cargo build 2>&1; then
        print_status 0 "Example build successful"
    else
        print_status 1 "Example build failed"
    fi
    cd ../..
fi
echo

# Run tests
echo "--- Running Tests ---"
echo "Running unit tests..."
if cargo test --lib 2>&1; then
    print_status 0 "Unit tests passed"
else
    print_status 1 "Unit tests failed"
fi

echo "Running all tests..."
if cargo test 2>&1; then
    print_status 0 "All tests passed"
else
    print_status 1 "Some tests failed"
fi
echo

# Code quality checks
echo "--- Code Quality Checks ---"
if command_exists rustfmt; then
    echo "Checking code formatting..."
    if cargo fmt -- --check 2>&1; then
        print_status 0 "Code formatting is correct"
    else
        print_status 1 "Code formatting issues found"
    fi
fi

if cargo clippy --version >/dev/null 2>&1; then
    echo "Running clippy..."
    if cargo clippy -- -D warnings 2>&1; then
        print_status 0 "Clippy checks passed"
    else
        print_status 1 "Clippy found issues"
    fi
fi
echo

# Documentation checks
echo "--- Documentation Checks ---"
echo "Checking for required documentation files..."
for file in README.md CONTRIBUTING.md LICENSE.md CODE_OF_CONDUCT.md CHANGELOG.md SECURITY.md; do
    if [ -f "$file" ]; then
        print_status 0 "$file exists"
    else
        print_status 1 "$file missing"
    fi
done

echo "Building documentation..."
if cargo doc --no-deps 2>&1; then
    print_status 0 "Documentation build successful"
else
    print_status 1 "Documentation build failed"
fi
echo

# File size analysis
echo "--- File Size Analysis ---"
echo "Checking for large files (>500 lines)..."
large_files_found=false
for file in src/*.rs; do
    if [ -f "$file" ]; then
        lines=$(wc -l < "$file")
        if [ "$lines" -gt 500 ]; then
            echo "⚠️  $file: $lines lines (>500)"
            large_files_found=true
        else
            echo "✅ $file: $lines lines"
        fi
    fi
done

if [ "$large_files_found" = false ]; then
    print_status 0 "No large files found"
fi
echo

# Summary
echo "=== Build Validation Summary ==="
echo "Validation completed at: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
echo
echo "If all checks passed, the build system is working correctly."
echo "If any checks failed, review the output above for specific issues."