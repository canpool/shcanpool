#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <maminjie1@huawei.com>
# SPDX-License-Identifier: MulanPSL-2.0

test_path_expand() {
    ut_assert_eq "$HOME" "$(path_expand ~)"

    local curdir="$PWD"
    cd $HOME
    local olddir="$PWD"
    cd $curdir
    ut_assert_eq "$olddir" "$OLDPWD"
}
