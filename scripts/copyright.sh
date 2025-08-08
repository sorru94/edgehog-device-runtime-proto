#!/usr/bin/env bash

# Copyright 2025 SECO Mind Srl
#
# SPDX-License-Identifier: Apache-2.0

##
# Annotates the files passed from stdin
#
# For example
#
#   git status --short | cut -f 2 -d ' ' | ./scripts/copyright.sh
#

set -exEuo pipefail

annotate() {
    reuse annotate \
        --copyright 'SECO Mind Srl' \
        --license 'Apache-2.0' \
        --copyright-prefix string \
        --merge-copyrights \
        --skip-unrecognized \
        "$@"
}

if [[ $# != 0 ]]; then
    annotate "$@"

    exit
fi

# Read from stdin line by line
while read -r line; do
    if [[ $line == '' ]]; then
        echo "Empty line, skipping" 1>&2
        continue
    fi

    annotate "$line"
done </dev/stdin
