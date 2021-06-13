#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <maminjie1@huawei.com>
# SPDX-License-Identifier: MulanPSL-2.0

test_type_is() {
    ut_assert_eq 1 "$(type_isfunction array_uniq)"
    ut_assert_ne 1 "$(type_isfunction array_xxx)"

    ut_assert_ne 1 "$(type_isalias ll)"
    ut_assert_eq 1 "$(type_isalias string_size)"

    ut_assert_eq 1 "$(type_iskeyword if)"
    ut_assert_eq 1 "$(type_iskeyword elif)"
    ut_assert_eq 1 "$(type_iskeyword else)"
    ut_assert_eq 1 "$(type_iskeyword fi)"
    ut_assert_eq 1 "$(type_iskeyword for)"
    ut_assert_eq 1 "$(type_iskeyword do)"
    ut_assert_eq 1 "$(type_iskeyword done)"
    ut_assert_eq 1 "$(type_iskeyword while)"
    ut_assert_eq 1 "$(type_iskeyword until)"
    ut_assert_eq 1 "$(type_iskeyword case)"
    ut_assert_eq 1 "$(type_iskeyword esac)"

    ut_assert_eq 1 "$(type_isfile ls)"  # ?
    ut_assert_eq 1 "$(type_isfile cat)"

    ut_assert_eq 1 "$(type_isbuiltin echo)"

    ut_assert_eq 1 "$(type_isbuiltin '[')"
    ut_assert_ne 1 "$(type_isbuiltin ']')"  # not builtin

    ut_assert_eq 1 "$(type_isbuiltin type)"
    ut_assert_eq 1 "$(type_isbuiltin set)"
}
