#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <canpool@163.com>
# SPDX-License-Identifier: MulanPSL-2.0

usage() {
    echo "Usage: ${PROG} [GLOBALOPTS] SUBCOMMAND [OPTS] [ARGS...]"
    echo "or: ${PROG} help SUBCOMMAND"
    echo ""
    echo "${DESC}"
    echo "Type '${PROG} help <subcommand>' for help on a specific subcommand."
    echo ""
    echo "Commands:"
    usage_commands
    echo ""
    echo "Global Options:"
    echo "    -h, --help          Show this help message and exit"
    echo "    -v, --version       Get version of ${PROG} and exit"
    echo ""
}

do_version() {
    if [ -n "$VERSION" ]; then
        echo "$PROG $VERSION"
        echo "Copyright (c) 2021 maminjie <canpool@163.com>"
        echo "License: MulanPSL-2.0 (https://license.coscl.org.cn/MulanPSL2)"
        echo "Contact https://gitee.com/icanpool/shcanpool"
    fi
}

do_usage() {
    local arg=$1

    case $arg in
        "-v"|"--version")
            do_version; exit
            ;;
        *)
            usage; exit
            ;;
    esac
}
