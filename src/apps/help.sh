#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <canpool@163.com>
# SPDX-License-Identifier: MulanPSL-2.0

method_def help

usage_help() {
    echo "help (h): Give detailed help on a specific sub-command"
    echo ""
    echo "usage:"
    echo "    ${PROG} help subcommand"
    echo ""
}

alias_def help h
# do_help subcmd
do_help() {
    local subcmd=$1

    if [ -z "$subcmd" ]; then
        usage_help; exit
    fi

    subcmd=$(alias_fullname "$subcmd")
    if [ "$(method_exists "$subcmd")" ]; then
        eval usage_$subcmd
    else
        echo "subcommand \"$subcmd\" not found..."
    fi
}
