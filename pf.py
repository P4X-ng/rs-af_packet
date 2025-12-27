#!/usr/bin/env python3
"""
pf.py - Build automation for af_packet library
Tiny Fabric runner with symbol-free DSL, parallel execution, and live output.
"""

import subprocess
import sys
import os
from pathlib import Path

def run_cmd(cmd, description=""):
    """Run a command with live output"""
    if description:
        print(f"==> {description}")
    print(f"Running: {cmd}")
    result = subprocess.run(cmd, shell=True, capture_output=False)
    if result.returncode != 0:
        print(f"ERROR: Command failed with exit code {result.returncode}")
        sys.exit(result.returncode)
    return result

def build():
    """Build the library"""
    run_cmd("./scripts/build.sh", "Building af_packet library")

def test():
    """Run all tests"""
    run_cmd("./scripts/test.sh", "Running test suite")

def bench():
    """Run performance benchmarks"""
    run_cmd("./scripts/bench.sh", "Running performance benchmarks")

def clean():
    """Clean build artifacts"""
    run_cmd("./scripts/clean.sh", "Cleaning build artifacts")

def docs():
    """Generate documentation"""
    run_cmd("./scripts/docs.sh", "Generating documentation")

def lint():
    """Run code quality checks"""
    run_cmd("./scripts/lint.sh", "Running code quality checks")

def security():
    """Run security audit"""
    run_cmd("./scripts/security.sh", "Running security audit")

def container_build():
    """Build in container environment"""
    run_cmd("./scripts/container-build.sh", "Building in container")

def integration_test():
    """Run SDK integration tests"""
    run_cmd("./scripts/integration-test.sh", "Running SDK integration tests")

def dev():
    """Development superset - build, test, lint"""
    build()
    test()
    lint()

def prod():
    """Production build with optimizations"""
    run_cmd("./scripts/prod-build.sh", "Production build")

def setup():
    """Setup development environment"""
    run_cmd("./scripts/setup.sh", "Setting up development environment")

def metrics():
    """Collect and display performance metrics"""
    run_cmd("./scripts/metrics.sh", "Collecting performance metrics")

def main():
    """Main entry point"""
    if len(sys.argv) < 2:
        print("Usage: pf.py <task> [params...]")
        print("\nAvailable tasks:")
        print("  build          - Build the library")
        print("  test           - Run all tests")
        print("  bench          - Run performance benchmarks")
        print("  clean          - Clean build artifacts")
        print("  docs           - Generate documentation")
        print("  lint           - Run code quality checks")
        print("  security       - Run security audit")
        print("  container-build - Build in container environment")
        print("  integration-test - Run SDK integration tests")
        print("  dev            - Development superset (build, test, lint)")
        print("  prod           - Production build with optimizations")
        print("  setup          - Setup development environment")
        print("  metrics        - Collect and display performance metrics")
        sys.exit(1)
    
    task = sys.argv[1]
    
    # Ensure scripts directory exists
    scripts_dir = Path("scripts")
    if not scripts_dir.exists():
        print("ERROR: scripts/ directory not found")
        sys.exit(1)
    
    # Map tasks to functions
    tasks = {
        'build': build,
        'test': test,
        'bench': bench,
        'clean': clean,
        'docs': docs,
        'lint': lint,
        'security': security,
        'container-build': container_build,
        'integration-test': integration_test,
        'dev': dev,
        'prod': prod,
        'setup': setup,
        'metrics': metrics,
    }
    
    if task not in tasks:
        print(f"ERROR: Unknown task '{task}'")
        print("Run 'pf.py' without arguments to see available tasks")
        sys.exit(1)
    
    # Execute the task
    tasks[task]()

if __name__ == "__main__":
    main()