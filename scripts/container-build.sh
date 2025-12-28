#!/bin/bash
# container-build.sh - Container-based build script

set -e

echo "Building in container environment..."

# Check for podman (preferred) or docker
if command -v podman &> /dev/null; then
    CONTAINER_CMD="podman"
elif command -v docker &> /dev/null; then
    CONTAINER_CMD="docker"
    echo "WARNING: Using docker instead of preferred podman"
else
    echo "ERROR: Neither podman nor docker found"
    exit 1
fi

echo "Using container runtime: $CONTAINER_CMD"

# Create Containerfile if it doesn't exist
if [ ! -f "Containerfile" ]; then
    echo "Creating Containerfile..."
    cat > Containerfile << 'EOF'
FROM rust:1.70-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Copy source code
COPY . .

# Build the project
RUN cargo build --release

# Run tests
RUN cargo test --release

CMD ["cargo", "build", "--release"]
EOF
fi

# Build container image
echo "Building container image..."
$CONTAINER_CMD build -t af_packet_build .

# Run build in container
echo "Running build in container..."
$CONTAINER_CMD run --rm -v $(pwd):/workspace af_packet_build

echo "Container build completed!"