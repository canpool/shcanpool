#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <maminjie1@huawei.com>
# SPDX-License-Identifier: MulanPSL-2.0

# Refers to https://gitee.com/api/v5/swagger
#
# Dependence:
#   log
#

__token=""      # access token


readonly GITEE_HEADER="Content-Type: application/json;charset=UTF-8"

# gitee_init token
gitee_init() {
    __token="$1"
}

# gitee_get url param
gitee_get() {
    curl -s -X GET -w 'HTTPCODE:%{http_code}' --header "$GITEE_HEADER" "$1?$2"
}

# gitee_post url value
gitee_post() {
    curl -s -X POST -w 'HTTPCODE:%{http_code}' --header "$GITEE_HEADER" "$1" -d "$2"
}

# gitee_delete url param
gitee_delete() {
    curl -s -X DELETE -w 'HTTPCODE:%{http_code}' --header "$GITEE_HEADER" "$1?$2"
}

# __gitee_get_http_xxx result
__gitee_get_http_msg() {
    echo "$1" | awk -F 'HTTPCODE:' '{print $1}'
}
__gitee_get_http_code() {
    echo "$1" | awk -F 'HTTPCODE:' '{print $2}'
}

# __gitee_parse_http_resp result message code
#   parse the response from gitee
# Params:
#   result  - [I] the response from gitee
#   message - [O] the message that was removed http code
#   code    - [O] the http code
# Returns: None
__gitee_parse_http_resp() {
    local message=""
    local code=""
    eval $(echo "$1" | awk -F "HTTPCODE:" '{
        if (NF >= 2) {
            printf("message=%s;code=%s;", $1, $2)
        }
    }')
    eval $2=\"$message\"
    eval $3=\"$code\"
}

# __gitee_handle_got_msg result
__gitee_handle_got_msg() {
    local result="$1"
    local code=$(__gitee_get_http_code "$result")
    if [ "$code" != "200" ]; then
        echo ""
    else
        __gitee_get_http_msg "$result"
    fi
}

# __gitee_handle_post_msg result
__gitee_handle_post_msg() {
    local result="$1"
    local code=$(__gitee_get_http_code "$result")
    if [ "$code" != "201" ]; then
        log_error "$result"
        return 1
    fi
    return 0
}

# gitee_get_one_repo owner repo
#   Get the specified repo of owner
# Returns:
#   "" or message
gitee_get_one_repo() {
    # https://gitee.com/api/v5/repos/{owner}/{repo}
    local url="https://gitee.com/api/v5/repos/$1/$2"
    local param="access_token=$__token"
    local result=$(gitee_get "$url" "$param")
    __gitee_handle_got_msg "$result"
}

# gitee_fork_repo owner repo
#   Fork the specified repo of owner
# Returns:
#   0 - success
#   1 - fail
gitee_fork_repo() {
    # https://gitee.com/api/v5/repos/{owner}/{repo}/forks
    local url="https://gitee.com/api/v5/repos/$1/$2/forks"
    local value="{\"access_token\":\"$__token\"}"
    local result=$(gitee_post "$url" "$value")
    __gitee_handle_post_msg "$result"
}

# gitee_delete_repo owner repo
#   Delete the specified repo of owner
# Returns:
#       0 - success
#       1 - fail
gitee_delete_repo() {
    # https://gitee.com/api/v5/repos/{owner}/{repo}
    local url="https://gitee.com/api/v5/repos/$1/$2"
    local param="access_token=$__token"
    local result=$(gitee_delete "$url" "$param")
    local code=$(__gitee_get_http_code "$result")
    if [ "$code" != "204" ]; then
        log_error "$result"
        return 1
    fi
    return 0
}

# gitee_create_pr owner repo title head
#   Create Pull Request
# Params:
#   owner - dst gitee project
#   head  - src gitee project
# Returns:
#   0 - success
#   1 - fail
gitee_create_pr() {
    # https://gitee.com/api/v5/repos/{owner}/{repo}/pulls
    local url="https://gitee.com/api/v5/repos/$1/$2/pulls"
    local value="{\"access_token\":\"$__token\",\"title\":\"$3\",\"head\":\"$4:master\",\"base\":\"master\"}"
    local result=$(gitee_post "$url" "$value")
    __gitee_handle_post_msg "$result"
}

# gitee_check_pr_compile owner repo number
#   Determine whether the Pull Request has been compiled successfully
# Returns:
#   0 - success
#   1 - fail
#   2 - warning
#   3 - error
gitee_check_pr_compile() {
    # https://gitee.com/api/v5/repos/{owner}/{repo}/pulls/{number}/comments
    local url="https://gitee.com/api/v5/repos/$1/$2/pulls/$3/comments"
    local param="access_token=$__token&page=1&per_page=100"
    local result=$(gitee_get "$url" "$param")
    local code=$(__gitee_get_http_code "$result")
    if [ "$code" != "200" ]; then
        log_error "$result"
        return 3
    fi
    result=$(echo "$result" | grep -oE '"body":"[^"]*"' | sed 's/\s*//g')
    local ret=1
    for i in $result; do
        local success=$(echo $i | grep -oE 'SUCCESS')
        local fail=$(echo $i | grep -oE '(FAILURE|FAILED)')
        local warning=$(echo $i | grep -oE 'WARNING')
        if [ -z "$success" ] || [ -n "$fail" ]; then
            continue
        fi
        if [ -z "$warning" ]; then
            return 0
        else
            ret=2
        fi
    done
    return $ret
}

# gitee_set_pr_comment owner repo number comments
#   Submit Pull Request comments
# Returns:
#   0 - success
#   1 - fail
gitee_set_pr_comment() {
    # https://gitee.com/api/v5/repos/{owner}/{repo}/pulls/{number}/comments
    local url="https://gitee.com/api/v5/repos/$1/$2/pulls/$3/comments"
    local value="{\"access_token\":\"$__token\",\"body\":\"$4\"}"
    local result=$(gitee_post "$url" "$value")
    __gitee_handle_post_msg "$result"
}


# gitee_check_pr_merge owner repo number
#   Determine whether the Pull Request has been merged
# Returns:
#   0 - merged
#   1 - unmerged
gitee_check_pr_merge() {
    # https://gitee.com/api/v5/repos/{owner}/{repo}/pulls/{number}/merge
    local url="https://gitee.com/api/v5/repos/$1/$2/pulls/$3/merge"
    local param="access_token=$__token"
    local result=$(gitee_get "$url" "$param")
    local code=$(__gitee_get_http_code "$result")
    if [ "$code" != "200" ]; then
        log_error "$result"
        return 1
    fi
    return 0
}

# gitee_get_issues owner repo state page
#   Get the all issues of repo
# Params:
#   state - open/progressing/closed/rejected/all
# Returns:
#   "" or issues
gitee_get_issues() {
    # https://gitee.com/api/v5/repos/{owner}/{repo}/issues
    local url="https://gitee.com/api/v5/repos/$1/$2/issues"
    local param="access_token=$__token&state=$3&sort=created&direction=desc&page=$4&per_page=100"
    local result=$(gitee_get "$url" "$param")
    __gitee_handle_got_msg "$result"
}

# gitee_get_issue_comments owner repo number
#   Get the all comments of issue
# Returns:
#   "" or comments
gitee_get_issue_comments() {
    # https://gitee.com/api/v5/repos/{owner}/{repo}/issues/{number}/comments
    local url="https://gitee.com/api/v5/repos/$1/$2/issues/$3/comments"
    local param="access_token=$__token&page=1&per_page=100&order=asc"
    local result=$(gitee_get "$url" "$param")
    __gitee_handle_got_msg "$result"
}

# gitee_set_issue_comment owner repo number comment
# Returns:
#   0 - success
#   1 - fail
gitee_set_issue_comment() {
    # https://gitee.com/api/v5/repos/{owner}/{repo}/issues/{number}/comments
    local url="https://gitee.com/api/v5/repos/$1/$2/issues/$3/comments"
    local value="{\"access_token\":\"$__token\",\"body\":\"$4\"}"
    local result=$(gitee_post "$url" "$value")
    __gitee_handle_post_msg "$result"
}
