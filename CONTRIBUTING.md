# Contributing to rs-af_packet

We welcome contributions to the rs-af_packet project! This document provides guidelines for contributing to this high-performance AF_PACKET bindings library for Rust.

## Getting Started

### Prerequisites

- Rust 1.70.0 or later
- Linux operating system (required for AF_PACKET support)
- Root privileges or appropriate capabilities for packet capture testing

### Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/P4X-ng/rs-af_packet.git
   cd rs-af_packet
   ```

2. Install dependencies:
   ```bash
   cargo build
   ```

3. Run tests:
   ```bash
   cargo test
   ```

## How to Contribute

### Reporting Issues

- Use the GitHub issue tracker to report bugs or request features
- Include detailed information about your environment (OS, Rust version, etc.)
- Provide minimal reproduction steps for bugs
- Check existing issues before creating new ones

### Submitting Changes

1. **Fork the repository** and create a feature branch from `main`
2. **Make your changes** following our coding standards
3. **Add tests** for new functionality
4. **Update documentation** as needed
5. **Run the test suite** to ensure nothing is broken
6. **Submit a pull request** with a clear description of changes

### Coding Standards

- Follow Rust standard formatting (`cargo fmt`)
- Address all Clippy warnings (`cargo clippy`)
- Write comprehensive tests for new features
- Document public APIs with rustdoc comments
- Keep unsafe code to a minimum and document safety requirements

### Testing Guidelines

- Write unit tests for all new functionality
- Include integration tests for complex features
- Test error conditions and edge cases
- Ensure tests pass on different Linux distributions
- Performance tests should be reproducible

### Documentation

- Update README.md for user-facing changes
- Add rustdoc comments for all public APIs
- Update CHANGELOG.md following [Keep a Changelog](https://keepachangelog.com/) format
- Include examples for new features

## Security Considerations

This library uses unsafe code for kernel interface operations. When contributing:

- Minimize unsafe code usage
- Document all unsafe blocks with safety justifications
- Review memory safety implications
- Consider privilege requirements for new features
- Report security issues privately to maintainers

## Code Review Process

1. All submissions require review from project maintainers
2. Reviews focus on correctness, performance, and safety
3. Address feedback promptly and professionally
4. Maintain a clean commit history

## Performance Guidelines

- Benchmark performance-critical changes
- Avoid unnecessary allocations in hot paths
- Consider zero-copy optimizations where possible
- Document performance characteristics of new features

## License

By contributing to this project, you agree that your contributions will be licensed under the GNU General Public License v3.0.

## Getting Help

- Open an issue for questions about contributing
- Review existing code and tests for examples
- Check the documentation and examples directory

## Recognition

Contributors will be acknowledged in the project documentation and release notes.

Thank you for contributing to rs-af_packet!