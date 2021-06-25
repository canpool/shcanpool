#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <canpool@163.com>
# SPDX-License-Identifier: MulanPSL-2.0

method_def checkenv

usage_checkenv() {
printf "checkenv (ce): Check the enviroment about tools/commands

usage:
    ${PROG} ce

"
}

alias_def checkenv ce
# do_checkenv
do_checkenv() {
    check_all
}

check_all() {
    # checker is: xxx_docheck
    local checkers=$(declare_functions | grep -E "^[a-zA-Z0-9]+_docheck")
    for cker in $checkers; do
        $cker
    done | sort -u
}

# check_command cmd
check_command() {
    local cmd="$1"
    if [ -z "$cmd" ]; then
        log_error "param invalid"; exit
    fi
    type "$cmd" &>/dev/null
    if [ $? -ne 0 ]; then
        color_print "$CLR_YELLOW" "$cmd: command not found..."
        return 1
    else
        color_print "$CLR_GREEN" "$cmd: which is $(which $cmd)"
        return 0
    fi
}

require_command() {
    check_command "$1"
    if [ $? -ne 0 ]; then
        exit
    fi
}

#
# commons check
#

vim_docheck() {
    check_command "vim"
}
