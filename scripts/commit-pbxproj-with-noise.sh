#!/bin/bash
# Commit a project.pbxproj change while the working tree has unrelated noise
# (locally modified pbxproj, dev-pod edits, ...).
#
# usage: commit-pbxproj-with-noise.sh <path/to/project.pbxproj> <edit-script> "<message>"
#
#   <edit-script> is run with ONE argument: the file to edit in place (a copy of
#   HEAD's version), e.g. a sed/ruby one-liner wrapper.
set -euo pipefail

path=$1; edit=$2; msg=$3
backup=$(mktemp)
cp "$path" "$backup"                      # your local (noisy) version

git show "HEAD:$path" > "$path"           # start from the committed version
"$edit" "$path"                           # apply ONLY the intended change
git add "$path"
git commit -m "$msg" -- "$path"           # pathspec commit ignores other staged files

cp "$backup" "$path"                      # restore the local copy
rm "$backup"
echo "committed $path; local working copy restored (re-apply your edit on top if needed)"
