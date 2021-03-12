#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <maminjie1@huawei.com>
# SPDX-License-Identifier: MulanPSL-2.0

# foreground
readonly CLR_BLACK="\033[30m"
readonly CLR_RED="\033[31m"
readonly CLR_GREEN="\033[32m"
readonly CLR_YELLOW="\033[33m"
readonly CLR_BLUE="\033[34m"
readonly CLR_PURPLE="\033[35m"
readonly CLR_SKYGREEN="\033[36m"
readonly CLR_WHITE="\033[37m"

# backgroud_foregroud
readonly CLR_BLACK_WHITE="\033[40;37m"
readonly CLR_RED_WHITE="\033[41;37m"
readonly CLR_GREEN_WHITE="\033[42;37m"
readonly CLR_YELLOW_WHITE="\033[43;37m"
readonly CLR_BLUE_WHITE="\033[44;37m"
readonly CLR_PURPLE_WHITE="\033[45;37m"
readonly CLR_WHITE_BLACK="\033[47;30m"
readonly CLR_SKYBLUE_WHITE="\033[46;37m"

# flicker
readonly CLR_FLICKER="\033[05m"

readonly CLR_OUTPUT="printf"
readonly CLR_TAILS="\033[0m\n"

# color_print color data
color_print() {
    ${CLR_OUTPUT} "$1$2${CLR_TAILS}"
}
