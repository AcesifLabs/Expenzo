#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/release.sh prepare vX.Y.Z+N [--base <branch>]
  ./scripts/release.sh publish vX.Y.Z+N

Example:
  ./scripts/release.sh prepare v1.0.0+2
  ./scripts/release.sh prepare v1.0.0+2 --base main
  ./scripts/release.sh publish v1.0.0+2

prepare (default base: develop) creates and pushes:
  Branch: release/mobile-vX.Y.Z+N

publish creates and pushes:
  Tag:    mobile-vX.Y.Z+N
EOF
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 2 || $# -gt 4 ]]; then
  echo "Error: invalid arguments." >&2
  usage
  exit 1
fi

MODE="$1"
VERSION="$2"
BASE_BRANCH="develop"

if [[ "$MODE" != "prepare" && "$MODE" != "publish" ]]; then
  echo "Error: invalid mode '$MODE'. Use 'prepare' or 'publish'." >&2
  usage
  exit 1
fi

if [[ "$MODE" == "prepare" && $# -eq 4 ]]; then
  if [[ "$3" != "--base" ]]; then
    echo "Error: expected optional flag '--base <branch>' for prepare mode." >&2
    usage
    exit 1
  fi
  BASE_BRANCH="$4"
fi

if [[ "$MODE" == "prepare" && $# -eq 3 ]]; then
  echo "Error: expected '--base <branch>' after third argument." >&2
  usage
  exit 1
fi

if [[ "$MODE" == "publish" && $# -ne 2 ]]; then
  echo "Error: publish mode expects exactly 2 arguments." >&2
  usage
  exit 1
fi

if [[ ! "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$ ]]; then
  echo "Error: invalid version '$VERSION'. Expected format: vX.Y.Z+N" >&2
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: this script must be run inside a git repository." >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Error: working tree is not clean. Commit/stash changes first." >&2
  exit 1
fi

RELEASE_BRANCH="release/mobile-${VERSION}"
RELEASE_TAG="mobile-${VERSION}"

echo "Fetching origin..."
git fetch origin

if [[ "$MODE" == "prepare" ]]; then
  echo "Checking out ${BASE_BRANCH}..."
  git checkout "${BASE_BRANCH}"

  echo "Updating local ${BASE_BRANCH}..."
  git pull --ff-only origin "${BASE_BRANCH}"

  if git show-ref --verify --quiet "refs/heads/${RELEASE_BRANCH}"; then
    echo "Error: local branch already exists: ${RELEASE_BRANCH}" >&2
    exit 1
  fi

  if git ls-remote --exit-code --heads origin "${RELEASE_BRANCH}" >/dev/null 2>&1; then
    echo "Error: remote branch already exists: origin/${RELEASE_BRANCH}" >&2
    exit 1
  fi

  echo "Creating release branch: ${RELEASE_BRANCH}"
  git checkout -b "${RELEASE_BRANCH}"

  echo "Pushing release branch..."
  git push -u origin "${RELEASE_BRANCH}"

  echo
  echo "Done. Created and pushed:"
  echo "  Branch: ${RELEASE_BRANCH}"
  echo "  Base:   ${BASE_BRANCH}"
  echo
  echo "Next steps:"
  echo "  1) Open PR from ${RELEASE_BRANCH} -> main"
  echo "  2) Merge PR"
  echo "  3) After merge, run: ./scripts/release.sh publish ${VERSION}"
  exit 0
fi

echo "Checking out main..."
git checkout main

echo "Updating local main..."
git pull --ff-only origin main

if git show-ref --verify --quiet "refs/tags/${RELEASE_TAG}"; then
  echo "Error: local tag already exists: ${RELEASE_TAG}" >&2
  exit 1
fi

if git ls-remote --exit-code --tags origin "refs/tags/${RELEASE_TAG}" >/dev/null 2>&1; then
  echo "Error: remote tag already exists: ${RELEASE_TAG}" >&2
  exit 1
fi

echo "Creating annotated tag: ${RELEASE_TAG}"
git tag -a "${RELEASE_TAG}" -m "Release ${RELEASE_TAG}"

echo "Pushing release tag..."
git push origin "${RELEASE_TAG}"

echo
echo "Done. Created and pushed:"
echo "  Tag: ${RELEASE_TAG}"
echo
echo "Next steps:"
echo "  Tag-triggered Android release workflow will run"

