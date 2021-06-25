#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <canpool@163.com>
# SPDX-License-Identifier: MulanPSL-2.0

method_def colordiff

usage_colordiff() {
printf "colordiff (cdiff): Wrap colordiff to compare FILES

usage:
    ${PROG} cdiff ...

process:
    perl colordiff.pl ...

"
}

alias_def colordiff cdiff
# do_colordiff ...
do_colordiff() {
    perl $PROJECT_DIR/plugins/perl/colordiff.pl $@
}

colordiff_docheck() {
    check_command "diff"
}
