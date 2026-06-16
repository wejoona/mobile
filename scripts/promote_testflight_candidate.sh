#!/usr/bin/env bash
set -euo pipefail

REMOTE="${REMOTE:-origin}"
SOURCE_BRANCH="${SOURCE_BRANCH:-develop}"
TARGET_BRANCH="${TARGET_BRANCH:-staging}"
RUN_CHECKS=1
CONFIRM=0
DRY_RUN=0

usage() {
  cat <<USAGE
Usage: scripts/promote_testflight_candidate.sh [--yes] [--skip-checks] [--dry-run]

Promotes the current develop commit to the staging branch watched by Codemagic/TestFlight.

Rules:
  - Run from a clean mobile repo.
  - Run on develop.
  - Keep pubspec marketing version below 2.0.0.
  - Codemagic owns the TestFlight build number from App Store Connect.

Options:
  --yes          Push without an interactive prompt.
  --skip-checks  Skip local analyzer/API contract check.
  --dry-run      Show what would be pushed without pushing.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes)
      CONFIRM=1
      shift
      ;;
    --skip-checks)
      RUN_CHECKS=0
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Refusing to promote: working tree is not clean." >&2
  git status --short >&2
  exit 1
fi

current_branch="$(git branch --show-current)"
if [[ "$current_branch" != "$SOURCE_BRANCH" ]]; then
  echo "Refusing to promote: current branch is '$current_branch', expected '$SOURCE_BRANCH'." >&2
  exit 1
fi

git fetch "$REMOTE" "$SOURCE_BRANCH" "$TARGET_BRANCH"

local_head="$(git rev-parse HEAD)"
remote_source="$(git rev-parse "$REMOTE/$SOURCE_BRANCH")"
if [[ "$local_head" != "$remote_source" ]]; then
  echo "Refusing to promote: local $SOURCE_BRANCH is not equal to $REMOTE/$SOURCE_BRANCH." >&2
  echo "Push or pull $SOURCE_BRANCH first." >&2
  exit 1
fi

version_line="$(awk '/^version:/ { print $2; exit }' pubspec.yaml)"
marketing_version="${version_line%%+*}"
major_version="${marketing_version%%.*}"

if [[ -z "$version_line" || -z "$major_version" || "$major_version" -ge 2 ]]; then
  echo "Refusing to promote: pubspec version '$version_line' must stay below 2.0.0." >&2
  exit 1
fi

if [[ "$RUN_CHECKS" -eq 1 ]]; then
  set +e
  dart analyze --format machine > analyze.txt
  ANALYZE_EXIT=$?
  set -e
  if grep -E '^(ERROR|WARNING)' analyze.txt; then
    echo "Analyzer errors/warnings found" >&2
    rm -f analyze.txt
    exit 1
  fi
  if [[ "$ANALYZE_EXIT" -gt 2 ]]; then
    cat analyze.txt >&2
    rm -f analyze.txt
    exit "$ANALYZE_EXIT"
  fi
  rm -f analyze.txt
  flutter test test/services/api_contract_alignment_test.dart
fi

source_commit="$(git rev-parse --short HEAD)"
target_commit="$(git rev-parse --short "$REMOTE/$TARGET_BRANCH" 2>/dev/null || true)"

echo "Ready to promote $SOURCE_BRANCH@$source_commit to $TARGET_BRANCH."
echo "Current $REMOTE/$TARGET_BRANCH: ${target_commit:-missing}"
echo "Marketing version: $marketing_version"
echo "TestFlight build number: assigned by Codemagic from App Store Connect"

if [[ "$DRY_RUN" -eq 1 ]]; then
  git push --dry-run "$REMOTE" "HEAD:refs/heads/$TARGET_BRANCH"
  exit 0
fi

if [[ "$CONFIRM" -ne 1 ]]; then
  read -r -p "Push this TestFlight candidate to $TARGET_BRANCH? [y/N] " answer
  case "$answer" in
    y|Y|yes|YES)
      ;;
    *)
      echo "Promotion cancelled."
      exit 0
      ;;
  esac
fi

git push "$REMOTE" "HEAD:refs/heads/$TARGET_BRANCH"
echo "Promoted $source_commit to $TARGET_BRANCH. Codemagic should create the TestFlight build."
