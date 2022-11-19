#!/usr/bin/env bash

SOLC_VERSION="${SOLC_VERSION:-0.8.6}"
echo "Using solc version $SOLC_VERSION"

shopt -s globstar
for i in contracts/**/*.sol; do # Whitespace-safe and recursive
    echo "Starting mythril analysis of contract $i"
    # Run mythril container
    # docker run --rm -it -v $(pwd):/tmp mythril/myth analyze --solc-json /tmp/mythril.json --solv $SOLC_VERSION /tmp/$i
    docker run -v $(pwd):/tmp mythril/myth analyze  --solc-json /tmp/mythril.json /tmp/$i --max-depth 12
    # docker run -v $(pwd):/tmp mythril/myth analyze /tmp/Class.sol
done
read