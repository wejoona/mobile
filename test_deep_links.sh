#!/bin/bash

# Deep Link Testing Script for JoonaPay Mobile App
# Usage: ./test_deep_links.sh [ios|android]

set -e

PLATFORM="${1:-android}"
PACKAGE="com.joonapay.wallet"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}JoonaPay Deep Link Testing Script${NC}"
echo "Testing platform: $PLATFORM"
echo ""

# Function to test iOS deep link
test_ios_link() {
    local link=$1
    local description=$2
    echo -e "${YELLOW}Testing:${NC} $description"
    echo "Link: $link"
    xcrun simctl openurl booted "$link"
    echo -e "${GREEN}✓${NC} Sent to simulator"
    echo ""
    sleep 2
}

# Function to test Android deep link
test_android_link() {
    local link=$1
    local description=$2
    echo -e "${YELLOW}Testing:${NC} $description"
    echo "Link: $link"
    adb shell am start -W -a android.intent.action.VIEW -d "$link" "$PACKAGE"
    echo -e "${GREEN}✓${NC} Sent to device/emulator"
    echo ""
    sleep 2
}

# Select test function based on platform
if [ "$PLATFORM" = "ios" ]; then
    test_link=test_ios_link
else
    test_link=test_android_link
fi

echo "=== Testing Custom Scheme (joonapay://) ==="
echo ""

# Test 1: Home/Wallet
$test_link "joonapay://wallet" "Open wallet home"
$test_link "joonapay://home" "Open home screen"

# Test 2: Send Money
$test_link "joonapay://send" "Open send flow (empty)"
$test_link "joonapay://send?to=%2B2250701234567" "Send to phone number"
$test_link "joonapay://send?to=%2B2250701234567&amount=50.00" "Send with amount"
$test_link "joonapay://send?to=%2B2250701234567&amount=50.00&note=Coffee%20payment" "Send with note"

# Test 3: Receive Money
$test_link "joonapay://receive" "Open receive screen"
$test_link "joonapay://receive?amount=100.00" "Receive with requested amount"

# Test 4: Transaction Detail
$test_link "joonapay://transaction/550e8400-e29b-41d4-a716-446655440000" "Transaction detail"

# Test 5: KYC
$test_link "joonapay://kyc" "KYC status"
$test_link "joonapay://kyc?tier=tier2" "KYC upgrade to tier 2"

# Test 6: Settings
$test_link "joonapay://settings" "Settings home"
$test_link "joonapay://settings/profile" "Profile settings"
$test_link "joonapay://settings/security" "Security settings"
$test_link "joonapay://settings/pin" "Change PIN"

# Test 7: Payment Link
$test_link "joonapay://pay/ABCD1234" "Pay via payment link"

# Test 8: Deposit & Withdraw
$test_link "joonapay://deposit" "Deposit screen"
$test_link "joonapay://deposit?method=orange" "Deposit via Orange Money"
$test_link "joonapay://withdraw" "Withdraw screen"

# Test 9: Bills & Airtime
$test_link "joonapay://bills" "Bill payments"
$test_link "joonapay://bills/cie-electricity" "CIE Electricity bill"
$test_link "joonapay://airtime" "Buy airtime"

# Test 10: Scanner
$test_link "joonapay://scan" "QR Scanner"
$test_link "joonapay://scan-to-pay" "Scan to pay"

# Test 11: Referrals
$test_link "joonapay://referrals" "Referral program"
$test_link "joonapay://referrals?code=JOHN2024" "Referral with code"

# Test 12: Notifications
$test_link "joonapay://notifications" "Notifications center"

echo ""
echo "=== Testing Universal Links / App Links (HTTPS) ==="
echo ""

if [ "$PLATFORM" = "ios" ]; then
    echo -e "${YELLOW}Note:${NC} Universal Links require AASA file deployed"
    echo "Test these manually in Safari on device:"
    echo "  https://app.joonapay.com/send?to=%2B2250701234567"
    echo "  https://app.joonapay.com/pay/ABCD1234"
    echo ""
else
    # Test App Links on Android
    $test_link "https://app.joonapay.com/send?to=%2B2250701234567" "Universal: Send money"
    $test_link "https://app.joonapay.com/pay/ABCD1234" "Universal: Payment link"
    $test_link "https://app.joonapay.com/transaction/550e8400-e29b-41d4-a716-446655440000" "Universal: Transaction"
fi

echo ""
echo -e "${GREEN}=== Testing Complete ===${NC}"
echo ""

# Verification commands
if [ "$PLATFORM" = "android" ]; then
    echo "=== Android App Links Verification ==="
    echo ""
    echo "Check verification status:"
    echo "  adb shell pm get-app-links $PACKAGE"
    echo ""
    echo "Re-verify if needed:"
    echo "  adb shell pm set-app-links --package $PACKAGE 0 app.joonapay.com"
    echo "  adb shell pm verify-app-links --re-verify $PACKAGE"
    echo ""
fi

echo "=== Manual Testing Checklist ==="
echo ""
echo "iOS:"
echo "  [ ] Safari: Type joonapay://send → Tap Open"
echo "  [ ] Notes: Type joonapay://send → Tap link"
echo "  [ ] Safari: Type https://app.joonapay.com/send (Universal Link)"
echo "  [ ] Long-press link → 'Open in JoonaPay' appears"
echo ""
echo "Android:"
echo "  [ ] Chrome: Type joonapay://send → Tap link"
echo "  [ ] Gmail: Tap deep link in email"
echo "  [ ] Chrome: Type https://app.joonapay.com/send (App Link)"
echo "  [ ] SMS: Tap deep link in message"
echo ""
echo "Both:"
echo "  [ ] Deep link from cold start (app closed)"
echo "  [ ] Deep link from background"
echo "  [ ] Deep link requires auth → saves for after login"
echo "  [ ] Invalid parameters show error"
echo ""
