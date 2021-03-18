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

    a1=($(dict_keys dict))
    a2=($(array_uniq a1))
    ut_assert_eq "key1 key2 repo" "$(array_all a2)"

    a1=($(dict_values dict))
    a2=($(array_uniq a1))
    ut_assert_eq "1 4 a" "$(array_all a2)"

    local b=$(dict_get dict repo)
    ut_assert_eq "1 2 3" "$(array_all $b)"
}
