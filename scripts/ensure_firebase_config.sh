#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${CM_BUILD_DIR:-$(pwd)}"
IOS_CONFIG="$ROOT_DIR/ios/Runner/GoogleService-Info.plist"
ANDROID_CONFIG="$ROOT_DIR/android/app/google-services.json"

decode_base64_env() {
  local var_name="$1"
  local output_path="$2"
  local value="${!var_name:-}"

  if [ -z "$value" ]; then
    return 0
  fi

  mkdir -p "$(dirname "$output_path")"
  if printf '%s' "$value" | base64 --decode > "$output_path" 2>/dev/null; then
    return 0
  fi
  printf '%s' "$value" | base64 -D > "$output_path"
}

has_placeholder_config() {
  local path="$1"
  [ -f "$path" ] || return 0

  grep -Eq \
    'DEVELOPMENT_PLACEHOLDER_KEY|000000000000|1:000000000000|com\.googleusercontent\.apps\.000000000000' \
    "$path"
}

decode_base64_env FIREBASE_IOS_PLIST_BASE64 "$IOS_CONFIG"
decode_base64_env FIREBASE_ANDROID_JSON_BASE64 "$ANDROID_CONFIG"

if [ "${REQUIRE_REAL_FIREBASE_CONFIG:-${CM_BUILD_ID:+true}}" = "true" ]; then
  missing=0

  if has_placeholder_config "$IOS_CONFIG"; then
    echo "iOS Firebase config is missing or still contains placeholder values." >&2
    echo "Set FIREBASE_IOS_PLIST_BASE64 in Codemagic with the base64-encoded GoogleService-Info.plist." >&2
    missing=1
  fi

  if has_placeholder_config "$ANDROID_CONFIG"; then
    echo "Android Firebase config is missing or still contains placeholder values." >&2
    echo "Set FIREBASE_ANDROID_JSON_BASE64 in Codemagic with the base64-encoded google-services.json." >&2
    missing=1
  fi

  if [ "$missing" -ne 0 ]; then
    exit 1
  fi
fi

echo "Firebase configuration check passed."
