#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <maminjie1@huawei.com>
# SPDX-License-Identifier: MulanPSL-2.0

test_string_len() {
    ut_assert_eq "5" "$(string_len "hello")"
    ut_assert_eq "5" "$(string_size "world")"
}

test_string_operate() {
    local str="hello world"

    # string length
    ut_assert_eq "11" "${#str}"
    ut_assert_eq "11" "$(expr length "$str")"
    ut_assert_eq "11" "$(expr "$str" : '.*')"

    # match string length from head
    ut_assert_eq "7" "$(expr match "$str" 'h[a-z]*.w')"
    ut_assert_eq "7" "$(expr "$str" : 'h[a-z]*.w')"
    # match string from head
    ut_assert_eq "hello" "$(expr match "$str" '\(.[a-z]\+\)')"
    ut_assert_eq "hello" "$(expr match "$str" '\([a-z]\+\)')"
    ut_assert_eq "hello" "$(expr "$str" : '\(.[a-z]\+\)')"
    ut_assert_eq "hello" "$(expr "$str" : '\(.....\)')"
    # match string from tail
    ut_assert_eq "world" "$(expr match "$str" '.*\([m-z][m-z][m-z][c-m][c-m]\)')"
    ut_assert_eq "world" "$(expr "$str" : '.*\(.....\)')"

    # index
    ut_assert_eq "3" "$(expr index "$str" lo)"  # l
    ut_assert_eq "5" "$(expr index "$str" mo)"  # o

    # substring
    ut_assert_eq "$str" "${str:0}"      # 0-based indexing
    ut_assert_eq "ello world" "${str:1}"
    ut_assert_eq "world" "${str:6}"
    ut_assert_eq "$str" "${str:-4}"     # value default operate
    ut_assert_eq "orld" "${str:(-4)}"
    ut_assert_eq "orld" "${str: -4}"    # with ' '
    ut_assert_eq "llo" "${str:2:3}"
    ut_assert_eq "he" "$(expr substr "$str" 1 2)" # 1-based indexing
    ut_assert_eq "e" "$(expr substr "$str" 2 1)"
    # "'"$str"'", string with space, otherwise "'$str'" is also fine
    ut_assert_eq "e" "$(echo | awk '{print substr("'"$str"'", 2, 1)}')"

    # string remove
    ut_assert_eq "lo world" "${str#*l}"     # remove shortest from head
    ut_assert_eq "d" "${str##*l}"           # remove longest from head
    ut_assert_eq "hello wor" "${str%l*}"    # remove shortest from tail
    ut_assert_eq "he" "${str%%l*}"          # remove longest from tail

    # string replace
    ut_assert_eq "hello bash" "${str/world/bash}"   # replace first matched string
    ut_assert_eq "heLLo worLd" "${str//l/L}"        # replace all matched string
    ut_assert_eq "$str" "${str/#ell/ELL}"           # if match head, then replace
    ut_assert_eq "Hello world" "${str/#h/H}"
    ut_assert_eq "hello worlD" "${str/%d/D}"        # if match tail, then replace
}

