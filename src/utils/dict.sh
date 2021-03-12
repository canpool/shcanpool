#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <maminjie1@huawei.com>
# SPDX-License-Identifier: MulanPSL-2.0

#
# Usage:
#   declare -A dict
#
#   dict_add dict k1 1
#   dict_add dict k2 2
#   dict["k3"]=3
#   dict_set dict k4 4
#
#   a=(5 6)
#   dict_add dict k5 a
#

# dict_add dict key value
dict_add() {
    dict_set $@
}

# dict_set dict key value
dict_set() {
    eval $1[$2]=$3
}

# dict_get dict key
dict_get() {
    eval echo \${$1[$2]}
}

# dict_exists dict key
dict_exists() {
    eval "
    for key in \${!$1[*]}; do
        [[ \"\${key}\" = \"\${2}\" ]] && echo 1 && return
    done
    "
}

# dict_keys dict
dict_keys() {
    eval echo \${!$1[@]}
}

# dict_values dict
dict_values() {
    eval echo \${$1[@]}
}
