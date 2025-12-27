#!/bin/bash
# setup.sh - Development environment setup script

set -e

echo "Setting up development environment..."

# Check for Rust installation
if ! command -v cargo &> /dev/null; then
    echo "Installing Rust toolchain..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ~/.cargo/env
fi

# Install required Rust components
echo "Installing Rust components..."
rustup component add rustfmt clippy

# Install development tools
echo "Installing development tools..."
cargo install cargo-audit || echo "cargo-audit already installed"
cargo install cargo-deny || echo "cargo-deny already installed"
cargo install criterion || echo "criterion already installed"

# Set up git hooks if git is available
if command -v git &> /dev/null && [ -d ".git" ]; then
    echo "Setting up git hooks..."
    mkdir -p .git/hooks
    
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Pre-commit hook for af_packet library

echo "Running pre-commit checks..."

# Format check
cargo fmt -- --check || {
    echo "Code formatting issues found. Run 'cargo fmt' to fix."
    exit 1
}

# Lint check
cargo clippy -- -D warnings || {
    echo "Clippy warnings found. Please fix before committing."
    exit 1
}

echo "Pre-commit checks passed!"
EOF
    
    chmod +x .git/hooks/pre-commit
fi

# Make all scripts executable
echo "Making scripts executable..."
chmod +x scripts/*.sh
chmod +x pf.py

# Create necessary directories
echo "Creating necessary directories..."
mkdir -p target
mkdir -p docs/generated

echo "Development environment setup completed!"
echo "You can now use: ./pf.py <task>"