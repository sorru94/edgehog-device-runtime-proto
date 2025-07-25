#!/usr/bin/env bash

# Copyright 2025 SECO Mind Srl
#
# SPDX-License-Identifier: Apache-2.0

set -exEuo pipefail

# Trap -e errors
trap 'echo "Exit status $? at line $LINENO from: $BASH_COMMAND"' ERR

# Remove everything until the first tag
sed '/^## \[[0-9]\+/,$!d' -i CHANGELOG.md

# prepend the unreleased changes
if [[ -n ${GITHUB_REPO:-} ]]; then
    git cliff --github-repo="$GITHUB_REPO" --unreleased --prepend CHANGELOG.md
else
    git cliff --unreleased --prepend CHANGELOG.md
fi
