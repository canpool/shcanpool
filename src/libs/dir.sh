#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <maminjie1@huawei.com>
# SPDX-License-Identifier: MulanPSL-2.0

# dir_exists dir
dir_exists() {
    [ -d "$1" ] && echo 1
}

# dir_get_subdirs dir
#   Returns all level 1 subdirectories under the specified directory
# Example:
#   Suppose the current directory is /test, and the /test directory contains t1, t2, t3.txt
#   dir_get_subdirs /test     # return t1, t2
dir_get_subdirs() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        return 1
    fi
    # matche that end in / and deletes /
    ls -F "$dir" | grep '/$' | sed 's/\/$//g'
}
