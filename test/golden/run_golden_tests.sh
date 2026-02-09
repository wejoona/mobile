#!/bin/bash

# Golden Test Runner Script
# Usage: ./run_golden_tests.sh [--update]
# Use --update flag to update golden files

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$PROJECT_DIR"

echo "================================================"
echo "USDC Wallet - Golden Test Runner"
echo "================================================"
echo ""

# Check for update flag
UPDATE_FLAG=""
if [[ "$1" == "--update" ]]; then
    UPDATE_FLAG="--update-goldens"
    echo "Mode: UPDATE GOLDENS"
else
    echo "Mode: VERIFY GOLDENS"
fi
echo ""

# Function to run tests for a specific feature
run_feature_tests() {
    local feature=$1
    local test_path="test/golden/$feature"
    
    if [[ -d "$test_path" ]]; then
        echo "----------------------------------------"
        echo "Running $feature golden tests..."
        echo "----------------------------------------"
        
        flutter test $UPDATE_FLAG "$test_path" --reporter compact 2>&1 || {
            echo "⚠️  Some $feature tests failed"
            return 1
        }
        echo "✅ $feature tests passed"
        echo ""
    else
        echo "⚠️  No tests found for $feature at $test_path"
    fi
}

# Track failures
FAILURES=0

# Run tests by feature area
FEATURES=(
    "auth"
    "splash"
    "onboarding"
    "wallet"
    "send"
    "deposit"
    "transactions"
    "settings"
    "kyc"
)

echo "Features to test: ${FEATURES[*]}"
echo ""

for feature in "${FEATURES[@]}"; do
    run_feature_tests "$feature" || ((FAILURES++))
done

echo "================================================"
if [[ $FAILURES -gt 0 ]]; then
    echo "❌ $FAILURES feature areas had failures"
    exit 1
else
    echo "✅ All golden tests passed!"
fi
echo "================================================"
