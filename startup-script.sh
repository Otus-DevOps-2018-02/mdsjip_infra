#!/usr/bin/env bash
set -e

readonly WORK_DIR='/opt/app'
readonly APP_URL='https://github.com/express42/reddit.git'
readonly REPO_DIR='reddit'

function install_ruby() {
    echo "installing ruby..."
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt install -y ruby-full ruby-bundler build-essential
    ruby -v 2>/dev/null && echo "successfully installed ruby" || (echo "failed to install ruby"; exit 1)
    bundle -v 2>/dev/null && echo "successfully installed ruby" || (echo "failed to install ruby"; exit 1)
}

function install_mongodb() {
    echo "installing mongodb..."
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
    sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
    sudo apt update -y
    sudo apt install -y mongodb-org
    sudo systemctl enable mongod
    sudo systemctl start mongod
    sudo systemctl status mongod
    systemctl is-active --quiet mongod && echo "successfully started mongod service"|| (echo "failed to start mongod service"; exit 1)
}

function deploy() {
    sudo rm -rf ${WORK_DIR} 2>/dev/null || echo "not found application directory, continuing"
    sudo mkdir -p ${WORK_DIR}
    sudo chmod -R 777 ${WORK_DIR}
    cd ${WORK_DIR}
    git clone -b monolith ${APP_URL} ${REPO_DIR} && cd ${REPO_DIR}
    bundle install
    sudo killall puma 2>/dev/null && echo "killed puma processes" || echo "not found puma processes, continuing"
    puma -d
    ps aux | grep -v 'grep' | grep 'puma' >/dev/null && echo "successfully deployed application"  || (echo "failed to deploy application"; exit 1)
}

install_ruby
install_mongodb
deploy

exit 0
