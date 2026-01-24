#!/bin/bash

# SECURITY: Release build script with obfuscation enabled
# This script builds production-ready APK/AAB and IPA with code obfuscation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}JoonaPay USDC Wallet - Secure Build${NC}"
echo -e "${GREEN}========================================${NC}"

# Check for required tools
command -v flutter >/dev/null 2>&1 || { echo -e "${RED}Flutter is not installed${NC}"; exit 1; }

# Create output directories
mkdir -p build/release/android
mkdir -p build/release/ios
mkdir -p build/release/debug-info

# Clean previous builds
echo -e "${YELLOW}Cleaning previous builds...${NC}"
flutter clean

# Get dependencies
echo -e "${YELLOW}Getting dependencies...${NC}"
flutter pub get

# Run analyzer
echo -e "${YELLOW}Running static analysis...${NC}"
flutter analyze

# Run tests
echo -e "${YELLOW}Running tests...${NC}"
flutter test || echo -e "${YELLOW}Warning: Some tests failed. Continue with caution.${NC}"

# Build Android APK with obfuscation
echo -e "${GREEN}Building Android APK with obfuscation...${NC}"
flutter build apk --release \
    --obfuscate \
    --split-debug-info=build/release/debug-info/android \
    --target-platform android-arm,android-arm64,android-x64

# Build Android App Bundle with obfuscation
echo -e "${GREEN}Building Android App Bundle with obfuscation...${NC}"
flutter build appbundle --release \
    --obfuscate \
    --split-debug-info=build/release/debug-info/android-bundle

# Copy Android artifacts
cp build/app/outputs/flutter-apk/app-release.apk build/release/android/
cp build/app/outputs/bundle/release/app-release.aab build/release/android/ 2>/dev/null || true

# Build iOS (only on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${GREEN}Building iOS with obfuscation...${NC}"
    flutter build ios --release \
        --obfuscate \
        --split-debug-info=build/release/debug-info/ios

    # Build IPA (requires valid signing)
    echo -e "${YELLOW}To build IPA, run:${NC}"
    echo "flutter build ipa --release --obfuscate --split-debug-info=build/release/debug-info/ios-ipa"
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Build complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Android APK: ${YELLOW}build/release/android/app-release.apk${NC}"
echo -e "Android AAB: ${YELLOW}build/release/android/app-release.aab${NC}"
echo ""
echo -e "${RED}IMPORTANT: Keep debug-info files for crash symbolication!${NC}"
echo -e "Debug symbols: ${YELLOW}build/release/debug-info/${NC}"
echo ""
echo -e "${YELLOW}Security features enabled:${NC}"
echo "  - Code obfuscation (Dart)"
echo "  - ProGuard/R8 minification (Android)"
echo "  - Debug info split (for secure crash reporting)"
echo ""
