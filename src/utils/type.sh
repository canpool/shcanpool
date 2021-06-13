#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <maminjie1@huawei.com>
# SPDX-License-Identifier: MulanPSL-2.0

# type_is name type
type_is() {
    [[ $# -ne 2 ]] && return
    local t=$(type -t "$1")
    [[ "$t" == "$2" ]] && echo 1
}

# type_isxxx name
type_isfunction() {
    type_is "$1" "function"
}

type_isalias() {
    type_is "$1" "alias"
}

type_iskeyword() {
    type_is "$1" "keyword"
}

type_isfile() {
    type_is "$1" "file"
}

type_isbuiltin() {
    type_is "$1" "builtin"
}
