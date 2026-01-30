#!/bin/bash

# Integration Test Runner Script
# Runs integration tests on simulator/emulator or real device

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
PLATFORM="ios"
DEVICE=""
HEADLESS=false
SCREENSHOTS=true
VERBOSE=false
TEST_FILE="integration_test/app_test.dart"

# Help message
show_help() {
    cat << EOF
Usage: ./integration_test.sh [OPTIONS]

Run integration tests for JoonaPay mobile app.

OPTIONS:
    -p, --platform PLATFORM     Platform to test (ios|android) [default: ios]
    -d, --device DEVICE         Specific device to use (optional)
    -f, --file FILE            Test file to run [default: integration_test/app_test.dart]
    -h, --headless             Run in headless mode (no UI)
    -s, --screenshots          Save screenshots on failure [default: true]
    -v, --verbose              Verbose output
    --help                     Show this help message

EXAMPLES:
    # Run all tests on iOS simulator
    ./integration_test.sh

    # Run tests on Android emulator
    ./integration_test.sh -p android

    # Run specific test file
    ./integration_test.sh -f integration_test/flows/auth_flow_test.dart

    # Run on specific device
    ./integration_test.sh -d "iPhone 15 Pro"

    # Verbose output
    ./integration_test.sh -v
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--platform)
            PLATFORM="$2"
            shift 2
            ;;
        -d|--device)
            DEVICE="$2"
            shift 2
            ;;
        -f|--file)
            TEST_FILE="$2"
            shift 2
            ;;
        -h|--headless)
            HEADLESS=true
            shift
            ;;
        -s|--screenshots)
            SCREENSHOTS=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Print configuration
echo -e "${GREEN}JoonaPay Integration Tests${NC}"
echo "=========================="
echo "Platform: $PLATFORM"
echo "Test file: $TEST_FILE"
echo "Verbose: $VERBOSE"
echo ""

# Change to mobile directory
cd "$(dirname "$0")/mobile" || exit 1

# Install dependencies
echo -e "${YELLOW}Installing dependencies...${NC}"
flutter pub get

# Generate localizations
echo -e "${YELLOW}Generating localizations...${NC}"
flutter gen-l10n

# List available devices
echo -e "${YELLOW}Available devices:${NC}"
flutter devices

# Get device ID if specified
DEVICE_ARG=""
if [ -n "$DEVICE" ]; then
    DEVICE_ARG="-d \"$DEVICE\""
fi

# Create screenshots directory
if [ "$SCREENSHOTS" = true ]; then
    mkdir -p integration_test/screenshots
fi

# Build verbose flag
VERBOSE_ARG=""
if [ "$VERBOSE" = true ]; then
    VERBOSE_ARG="--verbose"
fi

# Run tests
echo -e "${YELLOW}Running integration tests...${NC}"
echo ""

if [ "$PLATFORM" = "ios" ]; then
    # iOS tests
    if [ -n "$DEVICE_ARG" ]; then
        eval flutter test "$TEST_FILE" "$DEVICE_ARG" "$VERBOSE_ARG"
    else
        flutter test "$TEST_FILE" $VERBOSE_ARG
    fi
elif [ "$PLATFORM" = "android" ]; then
    # Android tests
    if [ -n "$DEVICE_ARG" ]; then
        eval flutter test "$TEST_FILE" "$DEVICE_ARG" "$VERBOSE_ARG"
    else
        flutter test "$TEST_FILE" $VERBOSE_ARG
    fi
else
    echo -e "${RED}Invalid platform: $PLATFORM${NC}"
    echo "Use 'ios' or 'android'"
    exit 1
fi

EXIT_CODE=$?

# Report results
echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
else
    echo -e "${RED}✗ Some tests failed${NC}"
    if [ "$SCREENSHOTS" = true ]; then
        echo -e "${YELLOW}Screenshots saved to: integration_test/screenshots/${NC}"
    fi
fi

exit $EXIT_CODE
