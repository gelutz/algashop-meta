#!/usr/bin/env bash
#
# Runs the test suites of every microservice.
#
# Each service wires its own test tasks (test / integrationTest / contractTest)
# into Gradle's `check`, so `check` is the single portable entry point:
#
#   ordering        -> test + integrationTest + contractTest
#   billing         -> test + integrationTest
#   product-catalog -> contractTest (its `test` task is disabled on purpose)
#
# Usage:
#   ./run-all-tests.sh                      # all services
#   ./run-all-tests.sh ordering billing     # only the named services
#   ./run-all-tests.sh -- --info            # extra args forwarded to Gradle
#   ./run-all-tests.sh ordering -- --info
#
# Exit code is 0 only when every selected service passes. Failing services do
# not abort the run: all of them are executed and reported in the summary.

set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICES_DIR="$ROOT_DIR/microservices"
GRADLE_TASK="check"

# Split "<services> -- <gradle args>".
services=()
gradle_args=()
seen_separator=0
for arg in "$@"; do
	if [[ $seen_separator -eq 0 && "$arg" == "--" ]]; then
		seen_separator=1
		continue
	fi
	if [[ $seen_separator -eq 1 ]]; then
		gradle_args+=("$arg")
	else
		services+=("$arg")
	fi
done

# No explicit selection: every directory holding a Gradle wrapper.
if [[ ${#services[@]} -eq 0 ]]; then
	for dir in "$SERVICES_DIR"/*/; do
		[[ -x "$dir/gradlew" ]] && services+=("$(basename "$dir")")
	done
fi

if [[ ${#services[@]} -eq 0 ]]; then
	echo "No microservices with a Gradle wrapper found in $SERVICES_DIR" >&2
	exit 1
fi

passed=()
failed=()

for service in "${services[@]}"; do
	service_dir="$SERVICES_DIR/$service"

	if [[ ! -x "$service_dir/gradlew" ]]; then
		echo "==> $service: no executable gradlew at $service_dir/gradlew" >&2
		failed+=("$service")
		continue
	fi

	echo
	echo "==================================================================="
	echo "==> Testing $service"
	echo "==================================================================="

	if (cd "$service_dir" && ./gradlew "$GRADLE_TASK" "${gradle_args[@]+"${gradle_args[@]}"}"); then
		passed+=("$service")
	else
		failed+=("$service")
	fi
done

echo
echo "==================================================================="
echo "Summary"
echo "==================================================================="
for service in "${passed[@]+"${passed[@]}"}"; do
	echo "  PASS  $service"
done
for service in "${failed[@]+"${failed[@]}"}"; do
	echo "  FAIL  $service"
done

# Test reports are per-service; point at them so failures are easy to open.
if [[ ${#failed[@]} -gt 0 ]]; then
	echo
	echo "HTML reports: microservices/<service>/build/reports/tests/"
	exit 1
fi
