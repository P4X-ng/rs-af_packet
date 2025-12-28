# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive unit tests for core functionality (10 test cases)
- Module-level documentation for all public modules
- Security documentation (SECURITY.md) with unsafe code review
- Example usage in library documentation
- CHANGELOG for tracking changes
- Complete CI/CD documentation suite (README.md, CONTRIBUTING.md, LICENSE.md, CODE_OF_CONDUCT.md)
- Build validation script for comprehensive testing
- Feature flags for conditional compilation in CI/CD environments
- Enhanced build scripts with proper error handling

### Changed
- Updated to Rust 2021 edition
- Updated repository URL to https://github.com/P4X-ng/rs-af_packet
- Made protocol structure fields public for better API access
- Improved README with features section and maintainer information
- Enhanced build system with dependency validation
- Improved test scripts with privilege-aware execution
- Fixed wildcard dependency specification in examples

### Fixed
- Fixed all Clippy warnings and errors
- Fixed lifetime annotation inconsistencies in `get_raw_packets()` and `get_block()`
- Fixed `size_of_ref` issues in socket and transmission code
- Fixed import ordering for consistency with rustfmt
- Updated module imports for Rust 2021 edition compatibility
- Fixed build system reliability for CI/CD environments
- Resolved dependency version conflicts

### Security
- Comprehensive unsafe code review and documentation
- Added security considerations to contribution guidelines
- Implemented privilege-aware test execution
- Enhanced error handling for security-sensitive operations

## [0.3.1] - Previous Release

Initial version tracking point. See git history for changes before this version.

[Unreleased]: https://github.com/P4X-ng/rs-af_packet/compare/v0.3.1...HEAD
[0.3.1]: https://github.com/P4X-ng/rs-af_packet/releases/tag/v0.3.1
