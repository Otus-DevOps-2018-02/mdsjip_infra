#!/usr/bin/env bash
set -e

echo "installing mongodb..."
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
sudo apt update -y
sudo apt install -y mongodb-org
sudo systemctl enable mongod
sudo systemctl start mongod
systemctl status mongod
systemctl is-active --quiet mongod && echo "successfully started mongod service" || (echo "failed to start mongod service"; exit 1)

exit 0
