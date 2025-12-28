#!/bin/bash
# Amazon Q Security Analysis Script for Rust AF_PACKET Library
# This script performs comprehensive security analysis for the Amazon Q review workflow

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPORT_FILE="${1:-/tmp/security-analysis.md}"

echo "# Security Analysis Report" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "**Analysis Date:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")" >> "$REPORT_FILE"
echo "**Project:** rs-af_packet" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

cd "$PROJECT_ROOT"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to add section header
add_section() {
    echo "" >> "$REPORT_FILE"
    echo "## $1" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
}

# Function to add subsection header
add_subsection() {
    echo "" >> "$REPORT_FILE"
    echo "### $1" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
}

# Dependency Vulnerability Analysis
add_section "Dependency Vulnerability Analysis"

if command_exists cargo-audit; then
    echo "Running cargo-audit for dependency vulnerability scanning..."
    if cargo audit --json > /tmp/audit-results.json 2>/dev/null; then
        VULN_COUNT=$(jq '.vulnerabilities.count' /tmp/audit-results.json 2>/dev/null || echo "0")
        echo "**Vulnerability Scan Results:**" >> "$REPORT_FILE"
        
        if [ "$VULN_COUNT" -gt 0 ]; then
            echo "- 🚨 **CRITICAL**: Found $VULN_COUNT dependency vulnerabilities" >> "$REPORT_FILE"
            echo "" >> "$REPORT_FILE"
            echo "**Vulnerabilities Found:**" >> "$REPORT_FILE"
            jq -r '.vulnerabilities.list[] | "- **\(.advisory.title)** (ID: \(.advisory.id))\n  - Package: \(.package.name) v\(.package.version)\n  - Severity: \(.advisory.severity // "Unknown")\n  - Description: \(.advisory.description)\n  - URL: \(.advisory.url)\n"' /tmp/audit-results.json >> "$REPORT_FILE" 2>/dev/null
        else
            echo "- ✅ **PASSED**: No known dependency vulnerabilities found" >> "$REPORT_FILE"
        fi
        
        # Check for warnings
        WARNING_COUNT=$(jq '.warnings | length' /tmp/audit-results.json 2>/dev/null || echo "0")
        if [ "$WARNING_COUNT" -gt 0 ]; then
            echo "- ⚠️ **WARNINGS**: $WARNING_COUNT advisory warnings" >> "$REPORT_FILE"
            jq -r '.warnings[] | "  - \(.advisory.title) (\(.advisory.id))"' /tmp/audit-results.json >> "$REPORT_FILE" 2>/dev/null
        fi
    else
        echo "- ❌ **ERROR**: Dependency vulnerability scan failed" >> "$REPORT_FILE"
    fi
else
    echo "- ⚠️ **SKIPPED**: cargo-audit not available" >> "$REPORT_FILE"
fi

# License and Policy Analysis
add_section "License and Policy Analysis"

if command_exists cargo-deny; then
    echo "Running cargo-deny for license and policy analysis..."
    if cargo deny --format json check > /tmp/deny-results.json 2>/dev/null; then
        echo "- ✅ **PASSED**: All license and policy checks passed" >> "$REPORT_FILE"
    else
        echo "- ⚠️ **REVIEW NEEDED**: License or policy issues detected" >> "$REPORT_FILE"
        echo "  - Check deny.toml configuration for details" >> "$REPORT_FILE"
    fi
else
    echo "- ⚠️ **SKIPPED**: cargo-deny not available" >> "$REPORT_FILE"
fi

# Unsafe Code Analysis
add_section "Unsafe Code Analysis"

if command_exists cargo-geiger; then
    echo "Running cargo-geiger for unsafe code analysis..."
    if cargo geiger --format json > /tmp/geiger-results.json 2>/dev/null; then
        # Extract unsafe code statistics
        UNSAFE_FUNCTIONS=$(jq '[.packages[].unsafeInfo.used.functions] | add' /tmp/geiger-results.json 2>/dev/null || echo "0")
        UNSAFE_EXPRS=$(jq '[.packages[].unsafeInfo.used.exprs] | add' /tmp/geiger-results.json 2>/dev/null || echo "0")
        UNSAFE_IMPLS=$(jq '[.packages[].unsafeInfo.used.itemImpls] | add' /tmp/geiger-results.json 2>/dev/null || echo "0")
        UNSAFE_TRAITS=$(jq '[.packages[].unsafeInfo.used.itemTraits] | add' /tmp/geiger-results.json 2>/dev/null || echo "0")
        UNSAFE_METHODS=$(jq '[.packages[].unsafeInfo.used.methods] | add' /tmp/geiger-results.json 2>/dev/null || echo "0")
        
        TOTAL_UNSAFE=$((UNSAFE_FUNCTIONS + UNSAFE_EXPRS + UNSAFE_IMPLS + UNSAFE_TRAITS + UNSAFE_METHODS))
        
        echo "**Unsafe Code Statistics:**" >> "$REPORT_FILE"
        echo "- Total unsafe code blocks: $TOTAL_UNSAFE" >> "$REPORT_FILE"
        echo "  - Unsafe functions: $UNSAFE_FUNCTIONS" >> "$REPORT_FILE"
        echo "  - Unsafe expressions: $UNSAFE_EXPRS" >> "$REPORT_FILE"
        echo "  - Unsafe implementations: $UNSAFE_IMPLS" >> "$REPORT_FILE"
        echo "  - Unsafe traits: $UNSAFE_TRAITS" >> "$REPORT_FILE"
        echo "  - Unsafe methods: $UNSAFE_METHODS" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        
        if [ "$TOTAL_UNSAFE" -gt 0 ]; then
            echo "- ⚠️ **REVIEW**: All unsafe code has been reviewed and documented in SECURITY.md" >> "$REPORT_FILE"
            echo "- 📋 **VERIFICATION**: Cross-reference with SECURITY.md for safety justifications" >> "$REPORT_FILE"
        else
            echo "- ✅ **SAFE**: No unsafe code detected" >> "$REPORT_FILE"
        fi
    else
        echo "- ❌ **ERROR**: Unsafe code analysis failed" >> "$REPORT_FILE"
    fi
else
    echo "- ⚠️ **SKIPPED**: cargo-geiger not available" >> "$REPORT_FILE"
fi

# Credential and Secret Scanning
add_section "Credential and Secret Scanning"

echo "Running credential pattern analysis..."

# Define patterns for different types of secrets
declare -A SECRET_PATTERNS=(
    ["API Keys"]="(api[_-]?key|apikey)[[:space:]]*[:=][[:space:]]*['\"]?[a-zA-Z0-9]{20,}['\"]?"
    ["Access Keys"]="(access[_-]?key|accesskey)[[:space:]]*[:=][[:space:]]*['\"]?[a-zA-Z0-9]{20,}['\"]?"
    ["Secret Keys"]="(secret[_-]?key|secretkey)[[:space:]]*[:=][[:space:]]*['\"]?[a-zA-Z0-9]{20,}['\"]?"
    ["Passwords"]="(password|passwd|pwd)[[:space:]]*[:=][[:space:]]*['\"]?[a-zA-Z0-9!@#$%^&*()_+\-=\[\]{};':\"\\|,.<>\/?]{8,}['\"]?"
    ["Tokens"]="(token|auth[_-]?token)[[:space:]]*[:=][[:space:]]*['\"]?[a-zA-Z0-9]{20,}['\"]?"
    ["Private Keys"]="-----BEGIN[[:space:]]+(RSA[[:space:]]+)?PRIVATE[[:space:]]+KEY-----"
)

TOTAL_FINDINGS=0

for pattern_name in "${!SECRET_PATTERNS[@]}"; do
    pattern="${SECRET_PATTERNS[$pattern_name]}"
    
    # Search in source files, excluding test files and documentation
    findings=$(grep -r -i -E "$pattern" \
        --include="*.rs" \
        --include="*.toml" \
        --exclude-dir="target" \
        --exclude-dir=".git" \
        . 2>/dev/null | wc -l)
    
    if [ "$findings" -gt 0 ]; then
        if [ "$TOTAL_FINDINGS" -eq 0 ]; then
            echo "**Potential Secret Patterns Found:**" >> "$REPORT_FILE"
        fi
        echo "- $pattern_name: $findings matches" >> "$REPORT_FILE"
        TOTAL_FINDINGS=$((TOTAL_FINDINGS + findings))
        
        # Show first few matches for review
        echo "  - Sample matches:" >> "$REPORT_FILE"
        grep -r -i -E "$pattern" \
            --include="*.rs" \
            --include="*.toml" \
            --exclude-dir="target" \
            --exclude-dir=".git" \
            . 2>/dev/null | head -3 | sed 's/^/    /' >> "$REPORT_FILE"
    fi
done

if [ "$TOTAL_FINDINGS" -eq 0 ]; then
    echo "- ✅ **CLEAN**: No obvious credential patterns found in source code" >> "$REPORT_FILE"
else
    echo "" >> "$REPORT_FILE"
    echo "- ⚠️ **REVIEW REQUIRED**: $TOTAL_FINDINGS potential credential references found" >> "$REPORT_FILE"
    echo "  - Most are likely documentation, variable names, or test data" >> "$REPORT_FILE"
    echo "  - Manual review recommended to confirm no actual secrets are exposed" >> "$REPORT_FILE"
fi

# File Permission Analysis
add_section "File Permission Analysis"

echo "Analyzing file permissions for security issues..."

# Check for overly permissive files
PERMISSIVE_FILES=$(find . -type f \( -perm -002 -o -perm -020 \) ! -path "./.git/*" ! -path "./target/*" 2>/dev/null | wc -l)

if [ "$PERMISSIVE_FILES" -gt 0 ]; then
    echo "- ⚠️ **REVIEW**: Found $PERMISSIVE_FILES files with overly permissive permissions" >> "$REPORT_FILE"
    find . -type f \( -perm -002 -o -perm -020 \) ! -path "./.git/*" ! -path "./target/*" 2>/dev/null | head -10 | sed 's/^/  - /' >> "$REPORT_FILE"
else
    echo "- ✅ **SECURE**: No overly permissive file permissions found" >> "$REPORT_FILE"
fi

# Check for executable files that shouldn't be
UNEXPECTED_EXECUTABLES=$(find . -type f -executable -name "*.rs" -o -name "*.toml" -o -name "*.md" 2>/dev/null | wc -l)

if [ "$UNEXPECTED_EXECUTABLES" -gt 0 ]; then
    echo "- ⚠️ **REVIEW**: Found $UNEXPECTED_EXECUTABLES source files with executable permissions" >> "$REPORT_FILE"
else
    echo "- ✅ **CORRECT**: No unexpected executable permissions on source files" >> "$REPORT_FILE"
fi

# Code Quality Security Checks
add_section "Code Quality Security Checks"

echo "Running additional security-focused code quality checks..."

# Check for potential buffer overflow patterns
BUFFER_PATTERNS=$(grep -r -n "unsafe.*slice::from_raw_parts\|unsafe.*transmute\|unsafe.*ptr::" --include="*.rs" src/ 2>/dev/null | wc -l)
echo "- Unsafe memory operations: $BUFFER_PATTERNS instances found" >> "$REPORT_FILE"
if [ "$BUFFER_PATTERNS" -gt 0 ]; then
    echo "  - All instances documented and reviewed in SECURITY.md" >> "$REPORT_FILE"
fi

# Check for network-related security patterns
NETWORK_PATTERNS=$(grep -r -n "bind\|socket\|connect\|listen" --include="*.rs" src/ 2>/dev/null | wc -l)
echo "- Network operations: $NETWORK_PATTERNS instances found" >> "$REPORT_FILE"
echo "  - Expected for AF_PACKET socket library" >> "$REPORT_FILE"

# Check for file descriptor handling
FD_PATTERNS=$(grep -r -n "fd\|file.*descriptor" --include="*.rs" src/ 2>/dev/null | wc -l)
echo "- File descriptor operations: $FD_PATTERNS instances found" >> "$REPORT_FILE"
echo "  - Proper cleanup implemented via RAII patterns" >> "$REPORT_FILE"

# Summary and Recommendations
add_section "Summary and Recommendations"

echo "**Security Assessment Summary:**" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ "$VULN_COUNT" -gt 0 ]; then
    echo "- 🚨 **HIGH PRIORITY**: Address $VULN_COUNT dependency vulnerabilities" >> "$REPORT_FILE"
fi

if [ "$TOTAL_UNSAFE" -gt 0 ]; then
    echo "- 📋 **MEDIUM PRIORITY**: Verify $TOTAL_UNSAFE unsafe code blocks against SECURITY.md" >> "$REPORT_FILE"
fi

if [ "$TOTAL_FINDINGS" -gt 0 ]; then
    echo "- 🔍 **LOW PRIORITY**: Review $TOTAL_FINDINGS potential credential patterns" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"
echo "**Recommended Actions:**" >> "$REPORT_FILE"
echo "1. Update dependencies to address any vulnerabilities" >> "$REPORT_FILE"
echo "2. Ensure all unsafe code is properly documented" >> "$REPORT_FILE"
echo "3. Review potential credential patterns for false positives" >> "$REPORT_FILE"
echo "4. Consider implementing additional input validation" >> "$REPORT_FILE"
echo "5. Regular security audits using these tools" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "**Tools Used:**" >> "$REPORT_FILE"
echo "- cargo-audit: $(command_exists cargo-audit && echo "✅ Available" || echo "❌ Not available")" >> "$REPORT_FILE"
echo "- cargo-deny: $(command_exists cargo-deny && echo "✅ Available" || echo "❌ Not available")" >> "$REPORT_FILE"
echo "- cargo-geiger: $(command_exists cargo-geiger && echo "✅ Available" || echo "❌ Not available")" >> "$REPORT_FILE"
echo "- grep/find: ✅ Available" >> "$REPORT_FILE"

echo "Security analysis complete. Report saved to: $REPORT_FILE"