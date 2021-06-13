#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <maminjie1@huawei.com>
# SPDX-License-Identifier: MulanPSL-2.0

__ut_line_no=""

# __ut_assert_trace
__ut_assert_trace() {
    echo -e "${FUNCNAME[3]}:${__ut_line_no:=$BASH_LINENO} (${FUNCNAME[@]:2})"
}

# __ut_assert_fail <failure> <command> <stdin>
__ut_assert_fail() {
    local failure=""
    if [ -n "$1" ]; then
        failure="\n$1"
    fi
    local report="[test] \"$2${3:+ <<< $3}\" failed.
$(__ut_assert_trace)$failure"

    echo -e "$report"
}

# ut_assert <command> <expected stdout> [stdin]
ut_assert() {
    local expected=$(echo -ne "${2:-}")
    local result="$(eval 2>/dev/null $1 <<< ${3:-})" || true
    if [[ "$result" == "$expected" ]]; then
        return
    fi
    result="$(sed -e :a -e '$!N;s/\n/\\n/;ta' <<< "$result")"
    [[ -z "$result" ]] && result="nothing" || result="\"$result\""
    [[ -z "$2" ]] && expected="nothing" || expected="\"$2\""
    __ut_line_no=$BASH_LINENO
    local errmsg="Expected: $expected\n  Actual: $result)"
    __ut_assert_fail "$errmsg" "$1" "$3"
}

# ut_assert_raises <command> <expected code> [stdin]
ut_assert_raises() {
    local status=0
    (eval $1 <<< ${3:-}) > /dev/null 2>&1 || status=$?
    local expected=${2:-0}
    if [[ "$status" -eq "$expected" ]]; then
        return
    fi
    __ut_line_no=$BASH_LINENO
    local errmsg="program terminated with code $status instead of $expected"
    __ut_assert_fail "$errmsg" "$1" "$3"
}

# ut_assert_eq <expected> <actual>
ut_assert_eq() {
    local expected=$(echo -ne "$1")
    local actual=$(echo -ne "$2")
    if [[ "X$expected" = "X$actual" ]]; then
        return
    fi
    __ut_line_no=$BASH_LINENO
    __ut_assert_fail "" "$1 = $2"
}

# ut_assert_ne <expected> <actual>
ut_assert_ne() {
    local expected=$(echo -ne "$1")
    local actual=$(echo -ne "$2")
    if [[ "X$expected" != "X$actual" ]]; then
        return
    fi
    __ut_line_no=$BASH_LINENO
    __ut_assert_fail "" "$1 != $2"
}


ut_usage() {
printf "Usage: ut [options] [cases]
A simple unit test framework

Options:
    -a, --all       Run all test cases
    -l, --list      List all test cases
    -h, --help      Show this help message and exit
"
}

ut_all() {
    declare_functions | grep -E "^test_[a-zA-Z0-9_]+"
}

__ut_run() {
    # test cases
    local tcs=""
    if [ $# -gt 0 ]; then
        tcs=$(get_list "$1")
        shift 1
    fi

    if [ -z "$tcs" ]; then
        tcs=$(ut_all)
    fi

    local __idx=1 # prevent conflict
    for tc in $tcs; do
        echo "$__idx) $tc $@"
        $tc $@
        ((__idx++))
    done
}

# ut_run [cases]
#   Run all test_xxx or some special test_xxx
ut_run() {
    local ARGS=$(getopt -o "hla" -l "help,list,all" -n "ut" -- "$@")
    eval set -- "${ARGS}"

    while true; do
        case "${1}" in
            -h|--help)
                ut_usage; exit
                ;;
            -l|--list)
                ut_all; exit
                ;;
            -a|--all)
                __ut_run; exit
                ;;
            --)
                shift; break
                ;;
        esac
    done

    if [ $# -eq 0 ]; then
        ut_usage; exit
    fi
    __ut_run "$@"
}

