#!/bin/bash

set -eu

#writed by Alexandr Khromlyuk
if [ "${1:-}" == '--help' ]; then
	echo "Info: $0 - install & deployment flask pg-12 gunicorn"
	echo "Usage: $0"
	echo "Example: $0"
	exit 0
fi

PWD="$(pwd)"

preparation() {
    echo "START install packages"
    yum update
    yum upgrade
    yum -y install vim gcc epel-release python3 python3-devel \
    openssl-server openssh-server yum-utils
    echo "SUCCESS install packages"
    return 0
}

preparation_env() {
    local __pip
    echo "START python3 venv and upgrade pip and install libs"
    ./python3 venv venv
    __pip="$(./venv/bin/python3 -m pip install)"
    $__pip --upgrade pip

    if [ -f requiremets.txt ]; then
        $__pip -r requiremets.txt
    else
        $__pip flask gunicorn psycopg2
    fi
    return 0
}

install_pg12() {
    echo "START install postgresql-12"
    yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
    yum-config-manager --enable pgdg12
    yum install -y postgresql12-server postgresql12 postgresql12-devel --skip-broken
    PATH=$PATH:/usr/pgsql-12/bin/
    echo "INIT DB"
    /usr/pgsql-12/bin/postgresql-12-setup initdb
    systemctl enable --now postgresql-12
    echo "SUCCESS install postgresql-12"
    return 0
}

main() {
    preparation
    install_pg12
    preparation_env
    echo "YOUR APP ENV $PWD"
    return 0
}

main "$@"
exit 0