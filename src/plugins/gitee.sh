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

# gitee_create_pr owner repo title head srcbranch dstbranch url
#   Create Pull Request
# Params:
#   owner - dst gitee project
#   head  - src gitee project
#   url - [O] the created pr-url
# Returns:
#   0 - success
#   1 - fail
gitee_create_pr() {
    if [ $# -ne 7 ]; then
        log_error "params invalid"; exit
    fi
    # https://gitee.com/api/v5/repos/{owner}/{repo}/pulls
    local url="https://gitee.com/api/v5/repos/$1/$2/pulls"
    local value="{\"access_token\":\"$__token\",\"title\":\"$3\",\"head\":\"$4:$5\",\"base\":\"$6\"}"
    local result=$(gitee_post "$url" "$value")
    __gitee_handle_post_msg "$result"
    if [ $? -ne 0 ]; then
        eval $7=""
        return 1
    fi
    # "html_url":"https://gitee.com/{owner}/{repo}/pulls/{number}"
    local __html_url__=$(echo "$result" | awk -F ',' '{print $3}' | sed 's/"//g' | sed 's/html_url://g')
    eval $7=\"$__html_url__\"
    return 0
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

# gitee_get_contents owner repo path ref
#   Get the content under the specific path of the owner/repo
# Params:
#   path - the file path
#   ref - branch, tag or commit
# Returns:
#   "" or contents
gitee_get_contents() {
    if [ $# -ne 4 ]; then
        log_error "params invalid"; exit
    fi
    # https://gitee.com/api/v5/repos/{owner}/{repo}/contents(/{path})
    local url="https://gitee.com/api/v5/repos/$1/$2/contents/$3"
    local param="access_token=$__token&ref=$4"
    local result=$(gitee_get "$url" "$param")
    local content=$(__gitee_handle_got_msg "$result")
    if [ -z "$content" ]; then
        echo ""; return
    fi
    # "content":"TmFtZtOG...." (base64)
    content=$(echo "$content" | awk -F ',' '{print $6}' | sed 's/"//g' | awk -F ':' '{print $2}')
    content=$(eval base64 -d <<< "$content")
    echo "$content"
}

# gitee_get_branches owner repo
#   Get the branches or owner/repo
# Returns:
#   "" or branches
gitee_get_branches() {
    if [ $# -ne 2 ]; then
        log_error "params invalid"; exit
    fi
    # https://gitee.com/api/v5/repos/{owner}/{repo}/branches
    local url="https://gitee.com/api/v5/repos/$1/$2/branches"
    local param="access_token=$__token"
    local result=$(gitee_get "$url" "$param")
    local branches=$(__gitee_handle_got_msg "$result")
    if [ -z "$branches" ]; then
        echo ""; return
    fi
    branches=$(echo "$branches" | awk -F ',' '{for (i=1;i<=NF;i++) {print $i}}' |\
        grep -E '^{|^\[{"name"' | sed 's/"//g' | awk -F ':' '{print $2}')
    echo "$branches"
}

# __gitee_get_rpeos reposjson
__gitee_get_repos() {
    echo "$1" | awk -F ',' '{for (i=1;i<=NF;i++) {print $i}}' |\
        sed 's/"//g' | grep "full_name" | awk -F '/' '{print $NF}' | sort -u
}

# gitee_get_user_repos username
#   Get the public repos of username
# Returns:
#   "" or repos
gitee_get_user_repos() {
    if [ $# -ne 1 ]; then
        log_error "params invalid"; exit
    fi
    # https://gitee.com/api/v5/users/{username}/repos
    local url="https://gitee.com/api/v5/users/$1/repos"
    local i=1
    while [ $i -le 1000 ]; do
        local param="access_token=$__token&type=all&sort=full_name&page=$i&per_page=100"
        local result=$(gitee_get "$url" "$param")
        local repos=$(__gitee_handle_got_msg "$result")
        if [ -z "$repos" ]; then
            return
        fi
        repos=$(__gitee_get_repos "$repos")
        if [ -z "$repos" ]; then
            return
        fi
        echo "$repos"
        ((i++))
    done
}

# gitee_get_org_repos org
#   Get the repos of a org
# Returns:
#   "" or repos
gitee_get_org_repos() {
    if [ $# -ne 1 ]; then
        log_error "params invalid"; exit
    fi
    # https://gitee.com/api/v5/orgs/{org}/repos
    local url="https://gitee.com/api/v5/orgs/$1/repos"
    local i=1
    while [ $i -le 1000 ]; do
        local param="access_token=$__token&type=all&page=$i&per_page=100"
        local result=$(gitee_get "$url" "$param")
        local repos=$(__gitee_handle_got_msg "$result")
        if [ -z "$repos" ]; then
            return
        fi
        repos=$(__gitee_get_repos "$repos")
        if [ -z "$repos" ]; then
            return
        fi
        echo "$repos"
        ((i++))
    done
}

