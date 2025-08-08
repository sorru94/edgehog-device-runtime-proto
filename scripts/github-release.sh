#!/usr/bin/env bash

# Copyright 2025 SECO Mind Srl
#
# SPDX-License-Identifier: Apache-2.0

set -exEuo pipefail

# Trap -e errors
trap 'echo "Exit status $? at line $LINENO from: $BASH_COMMAND"' ERR

TAG=$1

latest_tag=$(
    git tag --list |
        sort --version-sort |
        tail -n 1
)

if [[ $latest_tag == "$TAG" ]]; then
    latest="true"
else
    latest="false"
fi

if [[ -n ${GITHUB_REPO:-} ]]; then
    changelog=$(git cliff --strip all ---unreleased --tag="$TAG" --github-repo="$GITHUB_REPO")
else
    changelog=$(git cliff --strip all --unreleased --tag="$TAG")
fi

notes="### CHANGELOG

$changelog
"

gh release create "$TAG" \
    --verify-tag --fail-on-no-commits \
    --notes="$notes" --latest="$latest"
