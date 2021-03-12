#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <maminjie1@huawei.com>
# SPDX-License-Identifier: MulanPSL-2.0

#
# the format of config file as follow:
#
#   ---------config.ini---------
#   [section]
#   key = value
#   ----------------------------
#

# config_get file section key
config_get() {
    local file=$1
    local section=$2
    local key=$3
    local value=$(awk -F '=' \
        '/\['$section'\]/{a=1} (a==1 && $1~/'$key'/){a=0;sub(/^[[:blank:]]*|[[:blank:]]*$/,"",$2);print $2}' \
        $file)
    echo "$value"
}
