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
KORIDO_API_URL="${KORIDO_API_URL:-https://api.joonalabs.com/korido/v1}"
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
  env bash scripts/codex_mobile.sh help
  env bash scripts/codex_mobile.sh doctor
  env bash scripts/codex_mobile.sh pub-get
  env bash scripts/codex_mobile.sh devices
  env bash scripts/codex_mobile.sh sim-boot
  env bash scripts/codex_mobile.sh sim-enable-keyboard
  env bash scripts/codex_mobile.sh sim-clean
  env bash scripts/codex_mobile.sh sim-screenshot [path]
  env bash scripts/codex_mobile.sh sim-install
  env bash scripts/codex_mobile.sh device-install
  env bash scripts/codex_mobile.sh live-crawl
  env bash scripts/codex_mobile.sh live-login
  env bash scripts/codex_mobile.sh live-visual
  env bash scripts/codex_mobile.sh live-visual-capture
  env bash scripts/codex_mobile.sh ceo-screen-catalog [--from-existing [source output]]
  env bash scripts/codex_mobile.sh live-secondary
  env bash scripts/codex_mobile.sh live-e2e-wallet
  env bash scripts/codex_mobile.sh live-e2e-auth
  env bash scripts/codex_mobile.sh live-e2e-core
  env bash scripts/codex_mobile.sh analyze
  env bash scripts/codex_mobile.sh analyze-gate
  env bash scripts/codex_mobile.sh test-auth
  env bash scripts/codex_mobile.sh test-routes
  env bash scripts/codex_mobile.sh test-state
  env bash scripts/codex_mobile.sh test-money
  env bash scripts/codex_mobile.sh test-profile
  env bash scripts/codex_mobile.sh test-design
  env bash scripts/codex_mobile.sh test-settings
  env bash scripts/codex_mobile.sh analyze-settings
  env bash scripts/codex_mobile.sh codemagic-firebase-check
  env bash scripts/codex_mobile.sh codemagic-firebase-upload
  env bash scripts/codex_mobile.sh codemagic-builds
  env bash scripts/codex_mobile.sh codemagic-actions <build-id>
  env bash scripts/codex_mobile.sh codemagic-tests
  env bash scripts/codex_mobile.sh preflight
  env bash scripts/codex_mobile.sh build-ios-sim
  env bash scripts/codex_mobile.sh build-android-debug
  env bash scripts/codex_mobile.sh test <flutter-test-args...>

Defaults:
  DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer
  KORIDO_SIM_UDID=C796EC5E-0EBE-4E08-BF64-4DCDC84753D3
  KORIDO_SIM_BUNDLE_ID=com.joonapay.usdcWallet.dev
  KORIDO_SIM_BLOCKED_BUNDLE_IDS=ci.heritagepay.wallet
  KORIDO_ENV=staging
  KORIDO_API_URL=https://api.joonalabs.com/korido/v1
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

read_codemagic_token() {
  if [ -n "${CODEMAGIC_API_TOKEN:-}" ]; then
    printf '%s' "${CODEMAGIC_API_TOKEN}"
    return
  fi

  if [ -t 0 ]; then
    printf 'Codemagic API token: ' >&2
    stty -echo
    IFS= read -r token
    stty echo
    printf '\n' >&2
  else
    IFS= read -r token
  fi

  if [ -z "${token:-}" ]; then
    echo "Codemagic API token is required." >&2
    exit 64
  fi

  printf '%s' "${token}"
}

codemagic_api() {
  local method="$1"
  local path="$2"
  local token="$3"
  local data_file="${4:-}"

  if [ -n "${data_file}" ]; then
    curl -sS \
      -X "${method}" \
      -H "x-auth-token: ${token}" \
      -H "Content-Type: application/json" \
      -d @"${data_file}" \
      "https://codemagic.io${path}"
  else
    curl -sS \
      -X "${method}" \
      -H "x-auth-token: ${token}" \
      "https://codemagic.io${path}"
  fi
}

run_codemagic_firebase_check() {
  local ios_config="${FIREBASE_IOS_PLIST:-/Users/macbook/Downloads/GoogleService-Info.plist}"
  local android_config="${FIREBASE_ANDROID_JSON:-/Users/macbook/Downloads/google-services.json}"
  local temp_root
  local had_xtrace=false

  case "$-" in
    *x*)
      had_xtrace=true
      set +x
      ;;
  esac

  temp_root="$(mktemp -d "${TMPDIR:-/tmp}/korido-firebase-check.XXXXXX")"
  mkdir -p "${temp_root}/scripts"
  cp scripts/ensure_firebase_config.sh "${temp_root}/scripts/ensure_firebase_config.sh"

  (
    cd "${temp_root}"
    FIREBASE_IOS_PLIST_BASE64="$(base64 < "${ios_config}" | tr -d '\n')" \
      FIREBASE_ANDROID_JSON_BASE64="$(base64 < "${android_config}" | tr -d '\n')" \
      REQUIRE_REAL_FIREBASE_CONFIG=true \
      bash scripts/ensure_firebase_config.sh

    ios_bundle="$(plutil -extract BUNDLE_ID raw -o - ios/Runner/GoogleService-Info.plist)"
    android_package="$(python3 -c "import json; d=json.load(open('android/app/google-services.json')); print(d['client'][0]['client_info']['android_client_info']['package_name'])")"

    echo "iOS bundle: ${ios_bundle}"
    echo "Android package: ${android_package}"
  )

  if [ "${had_xtrace}" = true ]; then
    set -x
  fi
}

codemagic_group_id() {
  local token="$1"
  local app_id="${CODEMAGIC_APP_ID:-6a2c0018a82f6f396a172d16}"
  local group_name="${CODEMAGIC_VARIABLE_GROUP:-google_play_credentials}"

  codemagic_api GET "/api/v3/apps/${app_id}/variable-groups?page_size=100" "${token}" \
    | GROUP_NAME="${group_name}" python3 -c "import json,os,sys; data=json.load(sys.stdin).get('data', []); matches=[item['id'] for item in data if item.get('name')==os.environ['GROUP_NAME']]; print(matches[0] if matches else '')"
}

codemagic_variable_id() {
  local token="$1"
  local group_id="$2"
  local variable_name="$3"

  codemagic_api GET "/api/v3/variable-groups/${group_id}/variables?page_size=100&search=${variable_name}" "${token}" \
    | VARIABLE_NAME="${variable_name}" python3 -c "import json,os,sys; data=json.load(sys.stdin).get('data', []); matches=[item['id'] for item in data if item.get('name')==os.environ['VARIABLE_NAME']]; print(matches[0] if matches else '')"
}

codemagic_upsert_secure_variable() {
  local token="$1"
  local group_id="$2"
  local variable_name="$3"
  local variable_value="$4"
  local variable_id
  local payload

  variable_id="$(codemagic_variable_id "${token}" "${group_id}" "${variable_name}")"
  payload="$(mktemp "${TMPDIR:-/tmp}/korido-codemagic-var.XXXXXX.json")"

  if [ -n "${variable_id}" ]; then
    VARIABLE_NAME="${variable_name}" VARIABLE_VALUE="${variable_value}" \
      python3 -c "import json,os; print(json.dumps({'name': os.environ['VARIABLE_NAME'], 'value': os.environ['VARIABLE_VALUE'], 'secure': True}))" \
      > "${payload}"
    codemagic_api PATCH "/api/v3/variable-groups/${group_id}/variables/${variable_id}" "${token}" "${payload}" >/dev/null
    echo "Updated ${variable_name} as secure Codemagic variable."
  else
    VARIABLE_NAME="${variable_name}" VARIABLE_VALUE="${variable_value}" \
      python3 -c "import json,os; print(json.dumps({'secure': True, 'variables': [{'name': os.environ['VARIABLE_NAME'], 'value': os.environ['VARIABLE_VALUE']}]}))" \
      > "${payload}"
    codemagic_api POST "/api/v3/variable-groups/${group_id}/variables" "${token}" "${payload}" >/dev/null
    echo "Created ${variable_name} as secure Codemagic variable."
  fi

  rm -f "${payload}"
}

run_codemagic_firebase_upload() {
  local ios_config="${FIREBASE_IOS_PLIST:-/Users/macbook/Downloads/GoogleService-Info.plist}"
  local android_config="${FIREBASE_ANDROID_JSON:-/Users/macbook/Downloads/google-services.json}"
  local token
  local group_id
  local ios_value
  local android_value
  local had_xtrace=false

  run_codemagic_firebase_check

  case "$-" in
    *x*)
      had_xtrace=true
      set +x
      ;;
  esac

  token="$(read_codemagic_token)"
  group_id="$(codemagic_group_id "${token}")"
  if [ -z "${group_id}" ]; then
    echo "Could not find Codemagic variable group ${CODEMAGIC_VARIABLE_GROUP:-google_play_credentials}." >&2
    exit 66
  fi

  ios_value="$(base64 < "${ios_config}" | tr -d '\n')"
  android_value="$(base64 < "${android_config}" | tr -d '\n')"

  codemagic_upsert_secure_variable "${token}" "${group_id}" "FIREBASE_IOS_PLIST_BASE64" "${ios_value}"
  codemagic_upsert_secure_variable "${token}" "${group_id}" "FIREBASE_ANDROID_JSON_BASE64" "${android_value}"

  if [ "${had_xtrace}" = true ]; then
    set -x
  fi
}

run_codemagic_builds() {
  local token
  local team_id="${CODEMAGIC_TEAM_ID:-6a2bf92fcdcc3cc5baf1e63d}"
  local app_id="${CODEMAGIC_APP_ID:-6a2c0018a82f6f396a172d16}"
  local branch="${CODEMAGIC_BRANCH:-staging}"

  token="$(read_codemagic_token)"
  codemagic_api GET "/api/v3/teams/${team_id}/builds?app_id=${app_id}&branch=${branch}&page_size=10" "${token}" \
    | python3 -c "import json,sys; data=json.load(sys.stdin).get('data', []); [print(f\"{b['id']} #{b.get('index')} {b.get('status')} {b.get('branch')} {b.get('workflow',{}).get('id')} {b.get('created_at')}\") for b in data]"
}

run_codemagic_actions() {
  local build_id="${1:-}"
  local token

  if [ -z "${build_id}" ]; then
    echo "Usage: ./scripts/codex_mobile.sh codemagic-actions <build-id>" >&2
    exit 64
  fi

  token="$(read_codemagic_token)"
  codemagic_api GET "/api/v3/builds/${build_id}/actions?page_size=100" "${token}" \
    | python3 -c "import json,sys; data=json.load(sys.stdin).get('data', []); [print(f\"{a['name']} :: {a.get('status')}\") for a in data]"
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
  codemagic-firebase-check)
    run_codemagic_firebase_check
    ;;
  codemagic-firebase-upload)
    run_codemagic_firebase_upload
    ;;
  codemagic-builds)
    run_codemagic_builds
    ;;
  codemagic-actions)
    run_codemagic_actions "$@"
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
