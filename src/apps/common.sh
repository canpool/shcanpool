#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <canpool@163.com>
# SPDX-License-Identifier: MulanPSL-2.0

# print method/command usage brief information
usage_commands() {
    local methods=($(method_all))
    for m in ${methods[@]}; do
        eval local usageinfo=\"$(usage_${m} | head -n 1)\"
        printf "    %s\n" "$usageinfo"
    done | format_column ':'
}

# get_list strings/file
#   Get list from string list or list file
# Params:
#   strings - string list, like: "a b c ..."
#   file - list file, like:
#           f1) echo "a b c d" > f1
#           f2) for i in $list; do echo "$i" >> f2; done
# Example:
#   ---------test.sh---------
#   lst=$(get_list "$1")
#   for i in $lst; do
#       ...
#   done
#
#   function test() {
#       local pkgs=$(get_list "$1")
#       for pkg in $pkgs; do
#           ....
#       done
#   }
#
#   test "x y z"
#   -------------------------
#   > bash test.sh "a b c d"
#
get_list() {
    local lst=""

    if [ -f "$1" ]; then
        lst=$(cat "$1")
    else
        lst=$1
    fi

    echo "$lst"
}
