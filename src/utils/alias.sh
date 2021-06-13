#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <maminjie1@huawei.com>
# SPDX-License-Identifier: MulanPSL-2.0

# alias_def name a1 a2 ...
alias_def() {
    local name=$1
    for ((i=2;i<=$#;++i)); do
        local ax=$(eval echo "\$$i")
        if [ "$(alias_exists "$ax")" ]; then
            echo "Waring: alias $ax is exists"
        else
            eval __alias_${ax}=$name
        fi
    done
}

# alias_exists a
alias_exists() {
    eval test \$__alias_${1} && echo 1
}

# alias_fullname a
alias_fullname() {
    local a=$1
    if [ "$(alias_exists "$a")" ]; then
        eval echo \$__alias_"${a}"
    else
        echo "$a"
    fi
}

# alias_all
alias_all() {
    echo "${!__alias_@}" | sed 's/__alias_//g'
}
