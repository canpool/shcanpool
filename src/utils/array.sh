#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <maminjie1@huawei.com>
# SPDX-License-Identifier: MulanPSL-2.0

# array_all array
array_all() {
    eval echo \${$1[@]}
}

# array_exists array ele
array_exists() {
    eval "
    for m in \${${1}[@]}; do
        [ \"\${m}\" = \"\${2}\" ] && echo 1 && return
    done
    "
}

# array_uniq array
array_uniq() {
    eval echo "\${$1[@]}" | sed 's/ /\n/g' | sort -u
}

# array_add array ele
array_add() {
    eval $1=\(\${$1[@]} $2\)
}

# array_extend array array2
array_extend() {
    eval $1=\(\${$1[@]} \${$2[@]}\)
}

# array_len array
array_len() {
    eval echo \${#$1[@]}
}
