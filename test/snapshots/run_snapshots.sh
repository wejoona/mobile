#!/bin/bash

# JoonaPay Mobile - Snapshot Test Runner
# Runs all golden/snapshot tests with proper reporting

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          JoonaPay - Golden/Snapshot Test Runner          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if --update-goldens flag is provided
UPDATE_GOLDENS=""
if [[ "$1" == "--update" || "$1" == "-u" ]]; then
  UPDATE_GOLDENS="--update-goldens"
  echo -e "${YELLOW}⚠️  UPDATE MODE: Golden files will be updated${NC}"
  echo ""
fi

# Test files
TESTS=(
  "app_button_snapshot_test.dart"
  "app_card_snapshot_test.dart"
  "app_input_snapshot_test.dart"
  "app_select_snapshot_test.dart"
  "balance_card_snapshot_test.dart"
  "transaction_item_snapshot_test.dart"
)

TOTAL_TESTS=${#TESTS[@]}
PASSED=0
FAILED=0
FAILED_TESTS=()

echo -e "${BLUE}Running $TOTAL_TESTS snapshot test files...${NC}"
echo ""

# Run each test file
for test in "${TESTS[@]}"; do
  echo -e "${BLUE}→ Running: ${test}${NC}"

  if flutter test $UPDATE_GOLDENS "test/snapshots/${test}"; then
    echo -e "${GREEN}✓ Passed: ${test}${NC}"
    ((PASSED++))
  else
    echo -e "${RED}✗ Failed: ${test}${NC}"
    ((FAILED++))
    FAILED_TESTS+=("$test")
  fi
  echo ""
done

# Summary
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                      Test Summary                          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Total test files: ${TOTAL_TESTS}"
echo -e "${GREEN}Passed: ${PASSED}${NC}"
echo -e "${RED}Failed: ${FAILED}${NC}"
echo ""

# List failed tests if any
if [ $FAILED -gt 0 ]; then
  echo -e "${RED}Failed test files:${NC}"
  for test in "${FAILED_TESTS[@]}"; do
    echo -e "${RED}  - ${test}${NC}"
  done
  echo ""
  echo -e "${YELLOW}To update goldens: ./run_snapshots.sh --update${NC}"
  exit 1
else
  echo -e "${GREEN}✓ All snapshot tests passed!${NC}"

  if [ -n "$UPDATE_GOLDENS" ]; then
    echo -e "${GREEN}✓ Golden files updated successfully${NC}"
  fi
fi

echo ""

# Test count summary
echo -e "${BLUE}Test Coverage:${NC}"
echo "  • AppButton:        33 tests"
echo "  • AppCard:          15 tests"
echo "  • AppInput:         28 tests"
echo "  • AppSelect:        11 tests"
echo "  • BalanceCard:      21 tests"
echo "  • TransactionItem:  18 tests"
echo "  ─────────────────────────────"
echo "  Total:             126 tests"
echo ""
