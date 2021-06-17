#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <canpool@163.com>
# SPDX-License-Identifier: MulanPSL-2.0

method_def helloworld

usage_helloworld() {
printf "helloworld (hello): Hello to the world

usage:
    ${PROG} hello

"
}

alias_def helloworld hello
do_helloworld() {
    echo "hello world"
}
