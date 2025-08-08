#!/usr/bin/env bash

# Copyright 2025 SECO Mind Srl
#
# SPDX-License-Identifier: Apache-2.0

set -exEuo pipefail

# Trap -e errors
trap 'echo "Exit status $? at line $LINENO from: $BASH_COMMAND"' ERR

# Get last tag on branch
if ! tag=$(git describe --tags --abbrev=0); then
    echo "Nothing to describe"
    exit
fi

buf breaking --against "$GITHUB_REPO.git#branch=$tag,subdir=proto"
