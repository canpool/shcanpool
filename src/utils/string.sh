#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <maminjie1@huawei.com>
# SPDX-License-Identifier: MulanPSL-2.0

# string_len str
string_len() {
    local length=$(echo "$1" | wc -c)
    echo $(($length-1))
}

alias string_size="string_len"

# string_lower str
string_lower() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

# string_upper str
string_upper() {
    echo "$1" | tr '[:lower:]' '[:upper:]'
}
