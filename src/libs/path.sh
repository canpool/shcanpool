#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <maminjie1@huawei.com>
# SPDX-License-Identifier: MulanPSL-2.0

# path_expand path
#   Expand path (~)
path_expand() {
    eval echo "$1"
}

# path_absolute path
path_absolute() {
    readlink -f "$1"
}
