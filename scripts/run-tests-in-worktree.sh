#!/bin/bash
# Run a CocoaPods project's unit tests in an isolated git worktree, so the main
# checkout (and its uncommitted noise) is never touched.
#
# env: TEST_TARGET (defaults to the scheme name) = target that gets the overrides
# usage: run-tests-in-worktree.sh <branch> <workspace-or-project> <scheme> <udid> [-only-testing:Target/Suite]
#
#   <udid>  pin the simulator by id, never by name (names are ambiguous after
#           a few Xcode/runtime updates).
#
# Optional: if scripts/apply-test-target-overrides.rb exists next to this file
# (copy it into your project's tooling), it is re-applied before every run,
# because generator steps rewrite the project and wipe local overrides.
set -euo pipefail

branch=$1; container=$2; scheme=$3; udid=$4; shift 4
here=$(cd "$(dirname "$0")" && pwd)
repo=$(git rev-parse --show-toplevel)
wt="$repo/../wt-tests-$(echo "$branch" | tr '/' '-')"

if [ ! -d "$wt" ]; then
  git worktree add "$wt" "$branch"      # leaves the main checkout alone
fi
cd "$wt"

[ -f Podfile ] && { [ -d Pods ] || pod install; }

if [ -f "$here/apply-test-target-overrides.rb" ]; then
  ruby "$here/apply-test-target-overrides.rb" "$container" "${TEST_TARGET:-$scheme}"
fi

flag=-project; case "$container" in *.xcworkspace) flag=-workspace;; esac
xcodebuild "$flag" "$container" -scheme "$scheme" \
  -destination "id=$udid" \
  OTHER_SWIFT_FLAGS='$(inherited) -continue-building-after-errors' \
  "$@" test
# OTHER_SWIFT_FLAGS above lists ALL compile errors of bit-rotted test sources
# in one pass instead of stopping at the first one.
