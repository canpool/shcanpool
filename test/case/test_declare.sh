#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <maminjie1@huawei.com>
# SPDX-License-Identifier: MulanPSL-2.0

test_declare_functions() {
    ut_assert_eq "declare_functions" "$(declare_functions | grep "^declare_functions$")"
}
