#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode-beta.app/Contents/Developer}"

KORIDO_SIM_UDID="${KORIDO_SIM_UDID:-AE43EA55-17BE-4E86-9B7E-A0E564FEA4F8}"
KORIDO_ENV="${KORIDO_ENV:-staging}"
KORIDO_API_URL="${KORIDO_API_URL:-https://staging-korido-api.joonapay.com/api/v1}"
KORIDO_DEFAULT_OTP="${KORIDO_DEFAULT_OTP:-123456}"

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
  ./scripts/codex_mobile.sh sim-install
  ./scripts/codex_mobile.sh device-install
  ./scripts/codex_mobile.sh live-crawl
  ./scripts/codex_mobile.sh live-visual
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
  KORIDO_SIM_UDID=AE43EA55-17BE-4E86-9B7E-A0E564FEA4F8
  KORIDO_ENV=staging
  KORIDO_API_URL=https://staging-korido-api.joonapay.com/api/v1
  KORIDO_DEFAULT_OTP=123456

Override with env vars when needed. Keep this wrapper as the stable approval
surface for Codex simulator installs and verification commands.
USAGE
}

run_flutter() {
  flutter "$@" "${flutter_defines[@]}"
}

run_flutter_for_sim() {
  flutter "$@" -d "${KORIDO_SIM_UDID}" "${flutter_defines[@]}"
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
    flutter test "$@"
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
  live-visual)
    run_flutter_for_sim test integration_test/flows/live_api_visual_sweep_test.dart "$@"
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
    run_flutter build apk --debug "$@"
    ;;
  test)
    flutter test "$@"
    ;;
  *)
    echo "Unknown command: ${command}" >&2
    usage >&2
    exit 64
    ;;
esac
