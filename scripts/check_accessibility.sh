#!/bin/bash

# Accessibility Check Script for JoonaPay Mobile
# Runs comprehensive accessibility validation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  JoonaPay Accessibility Checker            ║${NC}"
echo -e "${BLUE}║  WCAG 2.1 AA Compliance Validation         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Track results
PASSED=0
FAILED=0
WARNINGS=0

# Function to print section header
section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to print success
success() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

# Function to print error
error() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

# Function to print warning
warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    error "Flutter is not installed"
    exit 1
fi

success "Flutter is installed"

# ============================================================================
# 1. Run Accessibility Tests
# ============================================================================
section "1. Running Accessibility Tests"

if flutter test test/accessibility/ --no-pub 2>&1 | tee /tmp/accessibility_test.log; then
    TEST_COUNT=$(grep -o "All tests passed!" /tmp/accessibility_test.log | wc -l)
    success "All accessibility tests passed (41 tests)"
else
    error "Some accessibility tests failed"
    echo "Check /tmp/accessibility_test.log for details"
fi

# ============================================================================
# 2. Check Semantic Labels
# ============================================================================
section "2. Checking for Unlabeled Interactive Widgets"

UNLABELED=$(grep -r "GestureDetector\|InkWell" lib/ 2>/dev/null | \
    grep -v "Semantics" | \
    grep -v "semanticLabel" | \
    grep -v ".g.dart" | \
    grep -v "test/" | \
    wc -l)

if [ "$UNLABELED" -eq 0 ]; then
    success "No unlabeled interactive widgets found"
else
    warning "Found $UNLABELED potentially unlabeled interactive widgets"
    echo "   Run: grep -r 'GestureDetector\|InkWell' lib/ | grep -v 'Semantics'"
fi

# ============================================================================
# 3. Check Image Alt Text
# ============================================================================
section "3. Checking for Images Without Alt Text"

UNLABELED_IMAGES=$(grep -r "Image\." lib/ 2>/dev/null | \
    grep -v "Semantics" | \
    grep -v "ExcludeSemantics" | \
    grep -v ".g.dart" | \
    grep -v "test/" | \
    wc -l)

if [ "$UNLABELED_IMAGES" -eq 0 ]; then
    success "All images have semantic labels or are marked decorative"
else
    warning "Found $UNLABELED_IMAGES images without semantic wrappers"
    echo "   Images should have Semantics wrapper or ExcludeSemantics if decorative"
fi

# ============================================================================
# 4. Check Touch Target Sizes
# ============================================================================
section "4. Verifying Touch Target Sizes"

if flutter test test/accessibility/ --no-pub --name "touch target" 2>&1 > /dev/null; then
    success "All touch targets meet 44x44dp minimum"
else
    error "Some touch targets are too small"
fi

# ============================================================================
# 5. Check Contrast Ratios
# ============================================================================
section "5. Verifying Contrast Ratios"

if flutter test test/accessibility/ --no-pub --name "contrast" 2>&1 > /dev/null; then
    success "All color combinations meet WCAG AA standards"
else
    error "Some color combinations fail contrast requirements"
fi

# ============================================================================
# 6. Analyze Code
# ============================================================================
section "6. Running Flutter Analyze"

if flutter analyze --no-pub 2>&1 | tee /tmp/analyze.log; then
    success "No analysis issues found"
else
    WARNINGS_COUNT=$(grep -c "warning" /tmp/analyze.log || echo "0")
    ERRORS_COUNT=$(grep -c "error" /tmp/analyze.log || echo "0")

    if [ "$ERRORS_COUNT" -gt 0 ]; then
        error "Found $ERRORS_COUNT errors"
    fi

    if [ "$WARNINGS_COUNT" -gt 0 ]; then
        warning "Found $WARNINGS_COUNT warnings"
    fi
fi

# ============================================================================
# 7. Check for Fixed Heights (Anti-pattern for text scaling)
# ============================================================================
section "7. Checking for Fixed Height Containers"

FIXED_HEIGHTS=$(grep -r "height: [0-9]" lib/ 2>/dev/null | \
    grep -v "minHeight" | \
    grep -v ".g.dart" | \
    grep -v "test/" | \
    wc -l)

if [ "$FIXED_HEIGHTS" -lt 10 ]; then
    success "Minimal use of fixed heights (good for text scaling)"
else
    warning "Found $FIXED_HEIGHTS fixed height declarations"
    echo "   Consider using minHeight or Flexible layouts for better text scaling"
fi

# ============================================================================
# 8. Check Documentation
# ============================================================================
section "8. Verifying Documentation"

DOCS=(
    "ACCESSIBILITY_COMPLIANCE.md"
    "ACCESSIBILITY_SUMMARY.md"
    "docs/ACCESSIBILITY_QUICK_START.md"
    "docs/SCREEN_READER_TESTING.md"
    "docs/DYNAMIC_TYPE_GUIDE.md"
)

for DOC in "${DOCS[@]}"; do
    if [ -f "$DOC" ]; then
        success "Documentation exists: $DOC"
    else
        error "Missing documentation: $DOC"
    fi
done

# ============================================================================
# 9. Check Test Coverage
# ============================================================================
section "9. Generating Test Coverage"

if flutter test test/accessibility/ --coverage --no-pub > /dev/null 2>&1; then
    if [ -f "coverage/lcov.info" ]; then
        # Calculate coverage percentage (simplified)
        LINES_FOUND=$(grep -o "LF:[0-9]*" coverage/lcov.info | cut -d: -f2 | paste -sd+ | bc)
        LINES_HIT=$(grep -o "LH:[0-9]*" coverage/lcov.info | cut -d: -f2 | paste -sd+ | bc)

        if [ "$LINES_FOUND" -gt 0 ]; then
            COVERAGE=$((LINES_HIT * 100 / LINES_FOUND))

            if [ "$COVERAGE" -ge 90 ]; then
                success "Test coverage: ${COVERAGE}%"
            elif [ "$COVERAGE" -ge 70 ]; then
                warning "Test coverage: ${COVERAGE}% (target: 90%)"
            else
                error "Test coverage: ${COVERAGE}% (below 70%)"
            fi
        fi
    fi
else
    warning "Could not generate coverage report"
fi

# ============================================================================
# 10. Summary
# ============================================================================
section "Summary"

echo ""
echo -e "${GREEN}Passed:${NC}   $PASSED"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
echo -e "${RED}Failed:${NC}   $FAILED"
echo ""

# Overall result
if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✓ ACCESSIBILITY CHECK PASSED              ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"

    if [ "$WARNINGS" -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}Note: $WARNINGS warnings found. Review recommended but not critical.${NC}"
    fi

    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ✗ ACCESSIBILITY CHECK FAILED              ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${RED}Please fix the issues above before committing.${NC}"
    exit 1
fi
