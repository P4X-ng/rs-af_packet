#!/bin/bash
# bench.sh - Performance benchmarking script

set -e

echo "Running performance benchmarks..."

# Check if benchmarks exist
if [ -d "benches" ]; then
    echo "Running cargo benchmarks..."
    cargo bench
else
    echo "No benchmark directory found, creating basic performance test..."
    
    # Create a simple benchmark if none exists
    mkdir -p benches
    cat > benches/basic_bench.rs << 'EOF'
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn benchmark_placeholder(c: &mut Criterion) {
    c.bench_function("placeholder", |b| b.iter(|| {
        // Placeholder benchmark - replace with actual performance tests
        black_box(1 + 1)
    }));
}

criterion_group!(benches, benchmark_placeholder);
criterion_main!(benches);
EOF
    
    # Add criterion to Cargo.toml if not present
    if ! grep -q "criterion" Cargo.toml; then
        echo "" >> Cargo.toml
        echo "[dev-dependencies]" >> Cargo.toml
        echo "criterion = \"0.5\"" >> Cargo.toml
        echo "" >> Cargo.toml
        echo "[[bench]]" >> Cargo.toml
        echo "name = \"basic_bench\"" >> Cargo.toml
        echo "harness = false" >> Cargo.toml
    fi
    
    echo "Basic benchmark structure created. Run again to execute benchmarks."
fi

echo "Performance benchmarking completed!"