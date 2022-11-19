#!/usr/bin/env bash

# Run eth-security-toolbox container
docker run -ti --rm -v $(pwd):/tmp trailofbits/eth-security-toolbox
read

