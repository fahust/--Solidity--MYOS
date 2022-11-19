#!/usr/bin/env bash

SOLC_VERSION="${SOLC_VERSION:-0.8.6}"
echo "Using solc version $SOLC_VERSION"

shopt -s globstar
for i in contracts/**/*.sol; do # Whitespace-safe and recursive
    echo "Starting slither analysis of contract $i"
    # Run slither container
    docker run --rm -it -v $(pwd):/tmp --entrypoint "slither" trailofbits/eth-security-toolbox \
        --solc-solcs-select $SOLC_VERSION /tmp/$i \
        --config-file /tmp/slither.json \
        --exclude-dependencies \
        --exclude-informational \
        --filter-paths "node_modules"
done
echo "ended"
read