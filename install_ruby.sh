#!/usr/bin/env bash
set -e

echo "installing ruby..."
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y ruby-full ruby-bundler build-essential
ruby -v 2>/dev/null && echo "successfully installed ruby" || (echo "failed to install ruby"; exit 1)
bundle -v 2>/dev/null && echo "successfully installed bundler" || (echo "failed to install bunlder"; exit 1)

exit 0
