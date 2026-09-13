#!/usr/bin/env bash

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$PROJECT_DIR/test-results"

detect_project_type() {
  if [[ -f "$PROJECT_DIR/gradlew" ]]; then
    printf '%s\n' 'gradle'
  elif [[ -f "$PROJECT_DIR/package.json" && -f "$PROJECT_DIR/package-lock.json" ]]; then
    printf '%s\n' 'node'
  else
    echo 'Error: unsupported project. Neither Gradle Wrapper nor npm project files were found.' >&2
    return 1
  fi
}

if [[ "${1:-}" == '--detect' ]]; then
  detect_project_type
  exit 0
fi

if [[ $# -ne 0 ]]; then
  echo "Usage: $0 [--detect]" >&2
  exit 2
fi

PROJECT_TYPE="$(detect_project_type)"

rm -rf "$RESULTS_DIR"
mkdir -p "$RESULTS_DIR"

case "$PROJECT_TYPE" in
  gradle)
    if ! command -v java >/dev/null 2>&1; then
      echo 'Error: Java is required to run the backend tests.' >&2
      exit 1
    fi

    JAVA_MAJOR_VERSION="$(java -version 2>&1 | awk -F '[".]' '/version/ { print $2; exit }')"
    if [[ "$JAVA_MAJOR_VERSION" != '21' ]]; then
      echo "Error: this backend requires JDK 21; detected Java ${JAVA_MAJOR_VERSION:-unknown}." >&2
      exit 1
    fi

    if [[ ! -x "$PROJECT_DIR/gradlew" ]]; then
      echo "Error: Gradle Wrapper is missing or is not executable: $PROJECT_DIR/gradlew" >&2
      exit 1
    fi

    GRADLE_RESULTS_DIR="$PROJECT_DIR/build/test-results/test"

    set +e
    "$PROJECT_DIR/gradlew" clean test
    TEST_EXIT_CODE=$?
    set -e

    if compgen -G "$GRADLE_RESULTS_DIR/*.xml" >/dev/null; then
      cp "$GRADLE_RESULTS_DIR"/*.xml "$RESULTS_DIR"/
    fi

    if [[ $TEST_EXIT_CODE -ne 0 ]]; then
      echo "Backend tests failed with exit code $TEST_EXIT_CODE." >&2
      exit "$TEST_EXIT_CODE"
    fi
    ;;
  node)
    if [[ ! -d "$PROJECT_DIR/node_modules" ]]; then
      echo "Error: dependencies are missing. Run 'npm ci' before running the tests." >&2
      exit 1
    fi

    (
      cd "$PROJECT_DIR"
      npm test
    )
    ;;
esac

if ! compgen -G "$RESULTS_DIR/*.xml" >/dev/null; then
  echo 'Error: no JUnit XML report was generated.' >&2
  exit 1
fi

echo "JUnit XML reports available in: $RESULTS_DIR"
