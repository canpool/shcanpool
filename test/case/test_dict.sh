#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <maminjie1@huawei.com>
# SPDX-License-Identifier: MulanPSL-2.0

test_dict() {
    declare -A dict

    local a=(1 2 3)
    dict_add dict repo a
    dict_add dict key1 1
    dict_add dict key2 3
    dict_add dict key2 4    # update

    ut_assert_eq "key2 key1 repo" "$(dict_keys dict)"
    ut_assert_eq "4 1 a" "$(dict_values dict)"

    local b=$(dict_get dict repo)
    ut_assert_eq "1 2 3" "$(array_all $b)"
}
