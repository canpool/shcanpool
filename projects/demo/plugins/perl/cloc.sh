#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <canpool@163.com>
# SPDX-License-Identifier: MulanPSL-2.0

method_def cloc

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
