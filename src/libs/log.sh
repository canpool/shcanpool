#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <maminjie1@huawei.com>
# SPDX-License-Identifier: MulanPSL-2.0

readonly LD_INFO="INFO"
readonly LD_DEBUG="DEBUG"
readonly LD_WARN="WARN"
readonly LD_ERROR="ERROR"
readonly LD_FATAL="FATAL"

# __log message level lineno
__log() {
    local dt="$(date +"%y-%m-%d %H:%M:%S")"
    local message=$1
    local level=$2
    local lineno=$3

    if [ -n "$lineno" ]; then
        lineno=":$lineno"
    fi
    local format="[$dt][$level][${FUNCNAME[2]}$lineno] $message"
    local funcname="TRACE: ${FUNCNAME[*]}"

    # print log
    case "$level" in
        "$LD_DEBUG")
            color_print "$CLR_GREEN" "$format"
            ;;
        "$LD_WARN")
            color_print "$CLR_YELLOW" "$format"
            ;;
        "$LD_ERROR")
            color_print "$CLR_RED" "$format"
            color_print "$CLR_RED" "$funcname"
            ;;
        "$LD_FATAL")
            color_print "$CLR_RED_WHITE" "$format"
            color_print "$CLR_RED_WHITE" "$funcname"
            ;;
        *)
            color_print "" "$format"
            ;;
    esac
}

# log_xxx message

log_info() {
    __log "$1" "$LD_INFO" "$BASH_LINENO"
}

log_debug() {
    __log "$1" "$LD_DEBUG" "$BASH_LINENO"
}

log_warn() {
    __log "$1" "$LD_WARN" "$BASH_LINENO"
}

log_error() {
    __log "$1" "$LD_ERROR" "$BASH_LINENO"
}

log_fatal() {
    __log "$1" "$LD_FATAL" "$BASH_LINENO"
}
