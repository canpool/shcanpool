#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <maminjie1@huawei.com>
# SPDX-License-Identifier: MulanPSL-2.0

test_array() {
    local a=(1 2 3)
    local b=(5 4 3)

    ut_assert_eq 3 "$(array_len a)"
    ut_assert_eq 1 "$(array_exists a 1)"
    ut_assert_ne 1 "$(array_exists a 4)"

    array_add a 4
    ut_assert_eq 4 "$(array_len a)"

    ut_assert_eq "1 2 3 4" "$(array_all a)"

    array_extend a b
    ut_assert_eq "1 2 3 4 5 4 3" "$(array_all a)"

    ut_assert_eq "1\n2\n3\n4\n5" "$(array_uniq a)"
}
