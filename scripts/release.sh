#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./scripts/release.sh vX.Y.Z+N

Example:
  ./scripts/release.sh v1.0.0+2

Creates and pushes:
  Branch: release/mobile-vX.Y.Z+N
  Tag:    mobile-vX.Y.Z+N
EOF
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -ne 1 ]]; then
  echo "Error: expected exactly 1 argument." >&2
  usage
  exit 1
fi

VERSION="$1"

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

if git show-ref --verify --quiet "refs/heads/${RELEASE_BRANCH}"; then
  echo "Error: local branch already exists: ${RELEASE_BRANCH}" >&2
  exit 1
fi

if git show-ref --verify --quiet "refs/tags/${RELEASE_TAG}"; then
  echo "Error: local tag already exists: ${RELEASE_TAG}" >&2
  exit 1
fi

if git ls-remote --exit-code --heads origin "${RELEASE_BRANCH}" >/dev/null 2>&1; then
  echo "Error: remote branch already exists: origin/${RELEASE_BRANCH}" >&2
  exit 1
fi

if git ls-remote --exit-code --tags origin "refs/tags/${RELEASE_TAG}" >/dev/null 2>&1; then
  echo "Error: remote tag already exists: ${RELEASE_TAG}" >&2
  exit 1
fi

echo "Fetching origin..."
git fetch origin

echo "Checking out main..."
git checkout main

echo "Updating local main..."
git pull --ff-only origin main

echo "Creating release branch: ${RELEASE_BRANCH}"
git checkout -b "${RELEASE_BRANCH}"

echo "Creating annotated tag: ${RELEASE_TAG}"
git tag -a "${RELEASE_TAG}" -m "Release ${RELEASE_TAG}"

echo "Pushing release branch..."
git push -u origin "${RELEASE_BRANCH}"

echo "Pushing release tag..."
git push origin "${RELEASE_TAG}"

echo
echo "Done. Created and pushed:"
echo "  Branch: ${RELEASE_BRANCH}"
echo "  Tag:    ${RELEASE_TAG}"
echo
echo "Next steps:"
echo "  1) Open PR from ${RELEASE_BRANCH} -> main"
echo "  2) Merge PR"
echo "  3) Tag-triggered Android release workflow will run"
