#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <maminjie1@huawei.com>
# SPDX-License-Identifier: MulanPSL-2.0

# file_exists file
file_exists() {
    [ -f "$1" ] && echo 1
}

# file_basename file
file_basename() {
    basename "${1}"
}

# file_dirname file
file_dirname() {
    dirname "${1}"
}
