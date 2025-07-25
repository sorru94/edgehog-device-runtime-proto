#!/usr/bin/env bash

# Copyright 2025 SECO Mind Srl
#
# SPDX-License-Identifier: Apache-2.0

set -exEuo pipefail

make

if ! git diff --quiet; then
    git diff
    exit 1
fi
