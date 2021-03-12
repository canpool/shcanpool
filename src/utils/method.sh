#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <maminjie1@huawei.com>
# SPDX-License-Identifier: MulanPSL-2.0

# method_def x y z ...
method_def() {
    for m in $@; do
        if [ $(method_exists "$m") ]; then
            echo "ERROR: method \"$m\" is exist"
        else
            array_add __methods $m
        fi
    done
}

# method_exists m
method_exists() {
    array_exists __methods $1
}

# method_all
method_all() {
    array_all __methods
}
