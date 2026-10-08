#!/bin/bash
# Proves the demo: NaiveTests fails to compile with the SWIFT_PACKAGE error,
# FixedTests builds and passes. Needs a booted-or-bootable simulator.
#
# usage: scripts/verify.sh [udid]      (default: first available iPhone)
set -uo pipefail
cd "$(dirname "$0")/../Demo"

udid=${1:-$(xcrun simctl list devices available -j | python3 -c '
import json,sys
d=json.load(sys.stdin)["devices"]
print(next(x["udid"] for k,v in d.items() if "iOS" in k for x in v if x["name"].startswith("iPhone")))')}
echo "simulator: $udid"

fail=0

echo "== NaiveTests (must FAIL to compile)"
out=$(xcodebuild -project Demo.xcodeproj -scheme NaiveTests -destination "id=$udid" test 2>&1)
if echo "$out" | grep -q "error: '../../Internal/VendorLibInternal.h' file not found\|VendorLibInternal.h' file not found"; then
  echo "OK: naive target breaks on the SWIFT_PACKAGE branch"
else
  echo "UNEXPECTED: naive target did not fail as documented"; fail=1
fi

echo "== FixedTests (must PASS)"
out=$(xcodebuild -project Demo.xcodeproj -scheme FixedTests -destination "id=$udid" test 2>&1)
if echo "$out" | grep -q "TEST SUCCEEDED"; then
  echo "$out" | grep -E "Executed [0-9]+ tests" | tail -1
else
  echo "UNEXPECTED: fixed target failed"; fail=1
fi
exit $fail
