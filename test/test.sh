#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <maminjie1@huawei.com>
# SPDX-License-Identifier: MulanPSL-2.0

current_path=$(dirname $(readlink -f "$0"))

readonly SHCANPOOL_DIR="$current_path/.."

source $SHCANPOOL_DIR/src/base/load.sh

load $SHCANPOOL_DIR/src/utils
load $SHCANPOOL_DIR/src/libs

load $SHCANPOOL_DIR/test/case

main() {
    ut_run "$@"
}

main "$@"
