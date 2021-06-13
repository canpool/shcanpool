#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <maminjie1@huawei.com>
# SPDX-License-Identifier: MulanPSL-2.0

shopt -s expand_aliases

# load dir
# load dir/*
# load dir/*.sh
# load file
load() {
    for file in $@; do
        if [ -f "$file" ]; then
            . "$file"
        elif [ -d "$file" ]; then
            load $(find "$file" -name "*.sh")
        fi
    done
}
