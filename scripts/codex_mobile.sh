#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode-beta.app/Contents/Developer}"

KORIDO_SIM_UDID="${KORIDO_SIM_UDID:-AE43EA55-17BE-4E86-9B7E-A0E564FEA4F8}"
KORIDO_ENV="${KORIDO_ENV:-staging}"
KORIDO_API_URL="${KORIDO_API_URL:-https://staging-korido-api.joonapay.com/api/v1}"

flutter_defines=(
  "--dart-define=ENV=${KORIDO_ENV}"
  "--dart-define=API_URL=${KORIDO_API_URL}"
)

usage() {
  cat <<'USAGE'
Korido mobile command wrapper

Usage:
  ./scripts/codex_mobile.sh help
  ./scripts/codex_mobile.sh sim-install
  ./scripts/codex_mobile.sh live-crawl
  ./scripts/codex_mobile.sh live-visual
  ./scripts/codex_mobile.sh live-secondary
  ./scripts/codex_mobile.sh test-settings
  ./scripts/codex_mobile.sh analyze-settings
  ./scripts/codex_mobile.sh test <flutter-test-args...>

Defaults:
  DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer
  KORIDO_SIM_UDID=AE43EA55-17BE-4E86-9B7E-A0E564FEA4F8
  KORIDO_ENV=staging
  KORIDO_API_URL=https://staging-korido-api.joonapay.com/api/v1

Override with env vars when needed. Keep this wrapper as the stable approval
surface for Codex simulator installs and verification commands.
USAGE
}

run_flutter_for_sim() {
  flutter "$@" -d "${KORIDO_SIM_UDID}" "${flutter_defines[@]}"
}

command="${1:-help}"
shift || true

case "${command}" in
  help|-h|--help)
    usage
    ;;
  sim-install)
    run_flutter_for_sim run --no-resident "$@"
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
  test)
    flutter test "$@"
    ;;
  *)
    echo "Unknown command: ${command}" >&2
    usage >&2
    exit 64
    ;;
esac
