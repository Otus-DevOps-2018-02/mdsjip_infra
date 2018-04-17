#!/usr/bin/env bash
set -e

git clone -b monolith https://github.com/express42/reddit.git && cd reddit
bundle install
puma -d
pgrep puma >/dev/null && echo "successfully deployed application" || ( echo "failed to deploy application"; exit 1)

exit 0
