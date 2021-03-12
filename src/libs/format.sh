#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <maminjie1@huawei.com>
# SPDX-License-Identifier: MulanPSL-2.0

# format_column s
#   Format column output with the separator s
format_column() {
    column -t -s "$1" | sed 's/\s*$//g'
}
