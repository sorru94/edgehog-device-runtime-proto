#!/usr/bin/env bash

# Copyright 2025 SECO Mind Srl
#
# SPDX-License-Identifier: Apache-2.0

set -exEuo pipefail

# Trap -e errors
trap 'echo "Exit status $? at line $LINENO from: $BASH_COMMAND"' ERR

FROM=$1
TO=$2
PR=$3

if [[ -n ${GITHUB_REPO:-} ]]; then
    changelog=$(git cliff -s all --github-repo="$GITHUB_REPO" -- "$FROM..$TO")
else
    changelog=$(git cliff -s all -- "$FROM..$TO")
fi

if [[ -n $changelog ]]; then
    body="
Review the changelog changes that will be generated.

# Changelog

$changelog
"
else
    body="The commits don't specify any user facing change to add to the CHANGELOG.md."
fi

gh pr comment "$PR" --edit-last --create-if-none --body="$body"
