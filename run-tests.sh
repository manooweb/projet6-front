#!/usr/bin/env bash

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$PROJECT_DIR/test-results"

if [[ ! -f "$PROJECT_DIR/package.json" || ! -f "$PROJECT_DIR/package-lock.json" ]]; then
  echo "Error: package.json and package-lock.json are required to run the frontend tests." >&2
  exit 1
fi

if [[ ! -d "$PROJECT_DIR/node_modules" ]]; then
  echo "Error: dependencies are missing. Run 'npm ci' before running the tests." >&2
  exit 1
fi

rm -rf "$RESULTS_DIR"

cd "$PROJECT_DIR"
npm test

if ! compgen -G "$RESULTS_DIR/*.xml" >/dev/null; then
  echo "Error: no JUnit XML report was generated." >&2
  exit 1
fi

echo "JUnit XML reports available in: $RESULTS_DIR"
