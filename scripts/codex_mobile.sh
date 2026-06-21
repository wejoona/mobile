#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

raise_file_limit() {
  ulimit -n 65536 2>/dev/null \
    || ulimit -n 32768 2>/dev/null \
    || ulimit -n 8192 2>/dev/null \
    || true
}

LOCK_DIR="${TMPDIR:-/tmp}/korido-codex-mobile.lock"
LOCK_ACQUIRED=false

release_stale_lock() {
  if [ ! -f "${LOCK_DIR}/pid" ]; then
    return
  fi

  local pid
  pid="$(cat "${LOCK_DIR}/pid" 2>/dev/null || true)"

  if [ -n "${pid}" ] && ! kill -0 "${pid}" 2>/dev/null; then
    rm -rf "${LOCK_DIR}"
  fi
}

acquire_mobile_lock() {
  local attempts=0

  release_stale_lock

  while ! mkdir "${LOCK_DIR}" 2>/dev/null; do
    release_stale_lock
    attempts=$((attempts + 1))

    if [ "${attempts}" -gt 600 ]; then
      echo "Timed out waiting for Korido mobile command lock: ${LOCK_DIR}" >&2
      exit 75
    fi

    if [ "$((attempts % 10))" -eq 0 ]; then
      echo "Waiting for another Korido mobile command to finish..." >&2
    fi

    sleep 1
  done

  LOCK_ACQUIRED=true
  printf '%s\n' "$$" > "${LOCK_DIR}/pid"
}

cleanup_mobile_lock() {
  if [ "${LOCK_ACQUIRED}" = true ]; then
    rm -rf "${LOCK_DIR}"
  fi
}

use_android_java_home() {
  if [ -n "${JAVA_HOME:-}" ] && "${JAVA_HOME}/bin/java" -version 2>&1 | grep -q 'version "17\.'; then
    return
  fi

  if command -v /usr/libexec/java_home >/dev/null 2>&1; then
    local java17_home
    java17_home="$(/usr/libexec/java_home -v 17 2>/dev/null || true)"

    if [ -n "${java17_home}" ]; then
      export JAVA_HOME="${java17_home}"
      export PATH="${JAVA_HOME}/bin:${PATH}"
    fi
  fi
}

raise_file_limit
acquire_mobile_lock
trap cleanup_mobile_lock EXIT
trap 'cleanup_mobile_lock; exit 130' INT
trap 'cleanup_mobile_lock; exit 143' TERM

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode-beta.app/Contents/Developer}"

KORIDO_SIM_UDID="${KORIDO_SIM_UDID:-C796EC5E-0EBE-4E08-BF64-4DCDC84753D3}"
KORIDO_SIM_BUNDLE_ID="${KORIDO_SIM_BUNDLE_ID:-com.joonapay.usdcWallet.dev}"
KORIDO_SIM_BLOCKED_BUNDLE_IDS="${KORIDO_SIM_BLOCKED_BUNDLE_IDS:-ci.heritagepay.wallet}"
KORIDO_ENV="${KORIDO_ENV:-staging}"
KORIDO_API_URL="${KORIDO_API_URL:-https://staging-korido-api.joonapay.com/api/v1}"
KORIDO_DEFAULT_OTP="${KORIDO_DEFAULT_OTP:-123456}"
export KORIDO_SIM_UDID
export KORIDO_SIM_BUNDLE_ID
export KORIDO_SIM_BLOCKED_BUNDLE_IDS
export KORIDO_ENV
export KORIDO_API_URL
export KORIDO_DEFAULT_OTP

flutter_defines=(
  "--dart-define=ENV=${KORIDO_ENV}"
  "--dart-define=API_URL=${KORIDO_API_URL}"
)

usage() {
  cat <<'USAGE'
Korido mobile command wrapper

Usage:
  ./scripts/codex_mobile.sh help
  ./scripts/codex_mobile.sh doctor
  ./scripts/codex_mobile.sh pub-get
  ./scripts/codex_mobile.sh devices
  ./scripts/codex_mobile.sh sim-boot
  ./scripts/codex_mobile.sh sim-enable-keyboard
  ./scripts/codex_mobile.sh sim-clean
  ./scripts/codex_mobile.sh sim-screenshot [path]
  ./scripts/codex_mobile.sh sim-install
  ./scripts/codex_mobile.sh device-install
  ./scripts/codex_mobile.sh live-crawl
  ./scripts/codex_mobile.sh live-login
  ./scripts/codex_mobile.sh live-visual
  ./scripts/codex_mobile.sh live-visual-capture
  ./scripts/codex_mobile.sh ceo-screen-catalog [--from-existing [source output]]
  ./scripts/codex_mobile.sh live-secondary
  ./scripts/codex_mobile.sh live-e2e-wallet
  ./scripts/codex_mobile.sh live-e2e-auth
  ./scripts/codex_mobile.sh live-e2e-core
  ./scripts/codex_mobile.sh analyze
  ./scripts/codex_mobile.sh analyze-gate
  ./scripts/codex_mobile.sh test-auth
  ./scripts/codex_mobile.sh test-routes
  ./scripts/codex_mobile.sh test-state
  ./scripts/codex_mobile.sh test-money
  ./scripts/codex_mobile.sh test-profile
  ./scripts/codex_mobile.sh test-design
  ./scripts/codex_mobile.sh test-settings
  ./scripts/codex_mobile.sh analyze-settings
  ./scripts/codex_mobile.sh codemagic-tests
  ./scripts/codex_mobile.sh preflight
  ./scripts/codex_mobile.sh build-ios-sim
  ./scripts/codex_mobile.sh build-android-debug
  ./scripts/codex_mobile.sh test <flutter-test-args...>

Defaults:
  DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer
  KORIDO_SIM_UDID=C796EC5E-0EBE-4E08-BF64-4DCDC84753D3
  KORIDO_SIM_BUNDLE_ID=com.joonapay.usdcWallet.dev
  KORIDO_SIM_BLOCKED_BUNDLE_IDS=ci.heritagepay.wallet
  KORIDO_ENV=staging
  KORIDO_API_URL=https://staging-korido-api.joonapay.com/api/v1
  KORIDO_DEFAULT_OTP=123456

Override with env vars when needed. Keep this wrapper as the stable approval
surface for Codex simulator installs and verification commands.

When `test` receives files under `test/e2e/`, it automatically enables the
live E2E defaults above so commands do not need inline environment prefixes.
USAGE
}

run_flutter() {
  flutter "$@" "${flutter_defines[@]}"
}

run_flutter_for_sim() {
  flutter "$@" -d "${KORIDO_SIM_UDID}" "${flutter_defines[@]}"
}

clean_simulator_app_state() {
  local blocked_bundle_id

  for blocked_bundle_id in ${KORIDO_SIM_BLOCKED_BUNDLE_IDS}; do
    xcrun simctl terminate "${KORIDO_SIM_UDID}" "${blocked_bundle_id}" >/dev/null 2>&1 || true
    xcrun simctl uninstall "${KORIDO_SIM_UDID}" "${blocked_bundle_id}" >/dev/null 2>&1 || true
  done

  xcrun simctl terminate "${KORIDO_SIM_UDID}" "${KORIDO_SIM_BUNDLE_ID}" >/dev/null 2>&1 || true
  xcrun simctl launch "${KORIDO_SIM_UDID}" "${KORIDO_SIM_BUNDLE_ID}"
}

enable_simulator_keyboard_input() {
  defaults write com.apple.iphonesimulator ConnectHardwareKeyboard -bool true || true
  osascript \
    -e 'tell application "Simulator" to activate' \
    -e 'tell application "System Events" to tell process "Simulator"' \
    -e 'try' \
    -e 'set keyboardInputItem to menu item "Send Keyboard Input to Device" of menu 1 of menu item "Input" of menu "I/O" of menu bar item "I/O" of menu bar 1' \
    -e 'if (value of attribute "AXMenuItemMarkChar" of keyboardInputItem) is missing value then click keyboardInputItem' \
    -e 'end try' \
    -e 'try' \
    -e 'set hardwareKeyboardItem to menu item "Connect Hardware Keyboard" of menu 1 of menu item "Keyboard" of menu "I/O" of menu bar item "I/O" of menu bar 1' \
    -e 'if (value of attribute "AXMenuItemMarkChar" of hardwareKeyboardItem) is missing value then click hardwareKeyboardItem' \
    -e 'end try' \
    -e 'end tell'
}

grant_simulator_test_permissions() {
  local service
  for service in camera contacts photos; do
    xcrun simctl privacy "${KORIDO_SIM_UDID}" grant "${service}" "${KORIDO_SIM_BUNDLE_ID}" >/dev/null 2>&1 || true
  done
}

run_analyze_gate() {
  mkdir -p .dart_tool
  set +e
  dart analyze --format machine > .dart_tool/codex_analyze.txt
  analyze_exit=$?
  set -e

  if grep -E '^(ERROR|WARNING)' .dart_tool/codex_analyze.txt; then
    echo "Analyzer errors/warnings found" >&2
    return 1
  fi

  if [ "${analyze_exit}" -gt 2 ]; then
    cat .dart_tool/codex_analyze.txt >&2
    return "${analyze_exit}"
  fi

  echo "Analyzer passed with no errors or warnings."
}

run_codemagic_tests() {
  mkdir -p .dart_tool
  find test -name '*_test.dart' \
    ! -path '*/golden/*' \
    ! -path '*/snapshots/*' \
    | sort > .dart_tool/codex_flutter_tests.txt
  xargs -n 40 flutter test < .dart_tool/codex_flutter_tests.txt
}

run_live_e2e() {
  RUN_E2E=true \
  RUN_LIVE_E2E=true \
  API_URL="${KORIDO_API_URL}" \
  DEFAULT_OTP="${KORIDO_DEFAULT_OTP}" \
    flutter test -j 1 "$@"
}

has_e2e_test_arg() {
  for arg in "$@"; do
    case "${arg}" in
      test/e2e|./test/e2e|*/test/e2e|test/e2e/*|*/test/e2e/*)
        return 0
        ;;
    esac
  done
  return 1
}

command="${1:-help}"
shift || true

case "${command}" in
  help|-h|--help)
    usage
    ;;
  doctor)
    flutter doctor -v "$@"
    ;;
  pub-get)
    flutter pub get "$@"
    ;;
  devices)
    flutter devices "$@"
    ;;
  sim-boot)
    xcrun simctl boot "${KORIDO_SIM_UDID}" "$@" 2>/dev/null || true
    xcrun simctl bootstatus "${KORIDO_SIM_UDID}" -b
    ;;
  sim-enable-keyboard)
    enable_simulator_keyboard_input
    ;;
  sim-clean)
    clean_simulator_app_state
    ;;
  sim-screenshot)
    screenshot_path="${1:-${TMPDIR:-/tmp}/korido-simulator.png}"
    xcrun simctl io "${KORIDO_SIM_UDID}" screenshot "${screenshot_path}"
    ;;
  sim-install)
    run_flutter_for_sim run --no-resident "$@"
    ;;
  device-install)
    if [ -z "${KORIDO_DEVICE_ID:-}" ]; then
      echo "Set KORIDO_DEVICE_ID to the physical device id first." >&2
      exit 64
    fi
    flutter run --no-resident -d "${KORIDO_DEVICE_ID}" "${flutter_defines[@]}" "$@"
    ;;
  live-crawl)
    run_flutter_for_sim test integration_test/flows/live_api_interactive_crawl_test.dart "$@"
    ;;
  live-login)
    run_flutter_for_sim test integration_test/flows/live_api_login_flow_test.dart "$@"
    ;;
  live-visual)
    run_flutter_for_sim test integration_test/flows/live_api_visual_sweep_test.dart "$@"
    ;;
  live-visual-capture)
    grant_simulator_test_permissions
    node scripts/capture_live_visual_sweep.mjs "$@"
    ;;
  ceo-screen-catalog)
    if [ "${1:-}" = "--from-existing" ]; then
      shift
      node scripts/create_ceo_screen_catalog.mjs "$@"
    else
      grant_simulator_test_permissions
      node scripts/capture_live_visual_sweep.mjs
      node scripts/create_ceo_screen_catalog.mjs
    fi
    ;;
  live-secondary)
    run_flutter_for_sim test integration_test/flows/live_api_secondary_surfaces_flow_test.dart "$@"
    ;;
  live-e2e-wallet)
    run_live_e2e \
      test/e2e/health_e2e_test.dart \
      test/e2e/wallet_e2e_test.dart \
      "$@"
    ;;
  live-e2e-auth)
    run_live_e2e \
      test/e2e/health_e2e_test.dart \
      test/e2e/auth_e2e_test.dart \
      "$@"
    ;;
  live-e2e-core)
    run_live_e2e \
      test/e2e/health_e2e_test.dart \
      test/e2e/auth_e2e_test.dart \
      test/e2e/wallet_e2e_test.dart \
      test/e2e/transactions_e2e_test.dart \
      test/e2e/devices_e2e_test.dart \
      "$@"
    ;;
  analyze)
    dart analyze "$@"
    ;;
  analyze-gate)
    run_analyze_gate
    ;;
  test-auth)
    flutter test \
      test/services/auth/auth_service_test.dart \
      test/services/session/session_unlock_contract_test.dart \
      test/services/session/session_manager_logout_contract_test.dart \
      test/services/session/user_session_repository_test.dart \
      "$@"
    ;;
  test-routes)
    flutter test \
      test/router/app_route_inventory_test.dart \
      test/router/app_routes_structure_test.dart \
      test/router/onboarding_routes_test.dart \
      "$@"
    ;;
  test-state)
    flutter test \
      test/integration/fsm_navigation_test.dart \
      test/services/session/session_unlock_contract_test.dart \
      test/services/biometric_service_test.dart \
      test/services/pin_service_test.dart \
      "$@"
    ;;
  test-money)
    flutter test \
      test/services/api_contract_alignment_test.dart \
      test/features/deposit/deposit_contract_test.dart \
      test/features/deposit/deposit_response_contract_test.dart \
      test/features/send/send_username_recipient_contract_test.dart \
      test/features/contacts/contacts_permission_contract_test.dart \
      test/features/contacts/contact_permission_flow_test.dart \
      test/services/limits/transaction_limits_contract_test.dart \
      "$@"
    ;;
  test-profile)
    flutter test \
      test/services/user_profile_contract_test.dart \
      test/widgets/user_avatar_test.dart \
      test/core/image_cache/image_cache_test.dart \
      "$@"
    ;;
  test-design)
    flutter test \
      test/design/theme/default_theme_test.dart \
      test/design/components/app_text_theme_test.dart \
      test/design/components/app_button_theme_test.dart \
      test/design/tokens/brand_color_calculator_test.dart \
      test/design/tokens/light_gradient_policy_test.dart \
      test/widgets/wallet/balance_card_test.dart \
      "$@"
    ;;
  test-settings)
    flutter test \
      test/features/settings/settings_contract_test.dart \
      test/features/settings/security_score_contract_test.dart \
      test/widgets/settings/security_view_test.dart \
      "$@"
    ;;
  analyze-settings)
    dart analyze \
      lib/features/settings/providers/security_settings_provider.dart \
      lib/features/settings/views/security_view.dart \
      test/features/settings/settings_contract_test.dart \
      "$@"
    ;;
  codemagic-tests)
    run_codemagic_tests
    ;;
  preflight)
    flutter pub get
    run_analyze_gate
    run_codemagic_tests
    ;;
  build-ios-sim)
    run_flutter build ios --simulator "$@"
    ;;
  build-android-debug)
    use_android_java_home
    run_flutter build apk --debug "$@"
    ;;
  test)
    if has_e2e_test_arg "$@"; then
      run_live_e2e "$@"
    else
      flutter test "$@"
    fi
    ;;
  *)
    echo "Unknown command: ${command}" >&2
    usage >&2
    exit 64
    ;;
esac
