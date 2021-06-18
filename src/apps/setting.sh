#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <canpool@163.com>
# SPDX-License-Identifier: MulanPSL-2.0

method_def init setting

# get config file
__config_file() {
    local cf="$CONFIG_FILE"
    if [ -z "$cf" ]; then
        cf="$HOME/.$PROG.conf"
    fi
    echo "$cf"
}

# __setting_get section key
__setting_get() {
    local cf="$(__config_file)"
    if [ -f "$cf" ]; then
        config_get "$cf" "$1" "$2"
    else
        echo ""
    fi
}

# setting_get section key
setting_get() {
    __setting_get "$1" "$2"
}

usage_init() {
printf "init (ini): Init ${PROG} environment

usage:
    ${PROG} init [options]

Options:
  -f, --force       Force init
  -h, --help        Show this help message and exit

"
}

alias_def init ini
# do_init [options]
do_init() {
    local ARGS=$(getopt -o ":hf" -l "help,force" -n "init" -- "$@")
    eval set -- "${ARGS}"

    local force=0
    while true; do
        case "${1}" in
            -h|--help)
                usage_init; exit
                ;;
            -f|--force)
                shift; force=1
                ;;
            --)
                shift; break
                ;;
            *)
                usage_init; exit
                ;;
        esac
    done

    setting_init "$force"
}

# setting_init force
setting_init() {
    local force="$1"
    local cf="$(__config_file)"
    local tf="$SHCANPOOL_DIR/config/template.conf"

    if [[ "$force" = "1" || ! -e "$cf" ]]; then
        if [ -e "$tf" ]; then
            cp "$tf" "$cf"
            echo "init $cf successed"
        else
            echo "No template config file $tf"
            echo "init $cf failed"
        fi
    else # Optional config
        echo "config file $cf exists"
    fi
}

usage_setting() {
printf "setting (set): Setting the config file

usage:
    ${PROG} set

"
}

alias_def setting set
# do_setting
do_setting() {
    local editor="vi"
    local file="$(__config_file)"

    type vim &>/dev/null
    if [ $? -eq 0 ]; then
        editor="vim"
    fi
    if [[ -z "$file" || ! -f "$file" ]]; then
        echo "No config file $file, try \"${PROG} init ...\" init it."; exit
    fi
    $editor "$file"
}
