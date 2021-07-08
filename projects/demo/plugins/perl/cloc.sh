#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <canpool@163.com>
# SPDX-License-Identifier: MulanPSL-2.0

method_def cloc clang

usage_cloc() {
printf "cloc (cl): Wrap cloc to count lines of code

usage:
    ${PROG} cl ...

process:
    perl cloc.pl ...

"
}

alias_def cloc cl
# do_cloc ...
do_cloc() {
    perl $PROJECT_DIR/plugins/perl/cloc.pl $@
}

usage_clang() {
printf "clang: Count languages of code

usage:
    ${PROG} clang DIR

"
}

# do_clang DIR
do_clang() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        usage_clang; exit
    fi
    # sed -e ':a;N;$!ba;s/\n/,/g' => replace \n to ,
    do_cloc --csv $dir | sed -r -e '1,/^files,language/d' -e '/^[0-9]+,SUM/,$d' | awk -F ',' '{print $2}'
}
