#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <canpool@163.com>
# SPDX-License-Identifier: MulanPSL-2.0

readonly CURRENT_DIR=$(dirname $(readlink -f "$0"))

readonly SHCANPOOL_DIR="$CURRENT_DIR/../.."

readonly PROG="demo"
readonly DESC="Shell Command Framework."
readonly VERSION="0.0.1"
readonly CONFIG_FILE="$HOME/.demo.conf"


source $SHCANPOOL_DIR/src/base/load.sh

load $SHCANPOOL_DIR/src/utils
load $SHCANPOOL_DIR/src/libs
load $SHCANPOOL_DIR/src/plugins
load $SHCANPOOL_DIR/src/apps

load $CURRENT_DIR/apps

main() {
    local subcmd=$1

    subcmd=$(alias_fullname "$subcmd")
    if [ "$(method_exists "$subcmd")" ]; then
        shift
        do_$subcmd "$@"
    else
        do_usage "$@"
    fi
}

main "$@"
