#!/usr/bin/env bash
# Copyright (c) 2021 maminjie <maminjie1@huawei.com>
# SPDX-License-Identifier: MulanPSL-2.0

# for testing, please ignore some failed asserts
test_bash_inner_var() {
    ut_assert_eq "/usr/bin/bash" "$BASH"
    # ut_assert_eq "/usr/share/Modules/init/bash" "$BASH_ENV"

    local bash_version="${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}.${BASH_VERSINFO[2]}\
(${BASH_VERSINFO[3]})-${BASH_VERSINFO[4]}"
    ut_assert_eq "$BASH_VERSION" "$bash_version"

    ut_assert_ne "" "$DIRSTACK"
    # ut_assert_eq "" "$EDITOR"

    ut_assert_eq "test_bash_inner_var" "$FUNCNAME"
    : echo "$LINENO"
    ut_assert_eq "$(($_+1))" "$LINENO"

    local ids="$(whoami).$$.$PPID" # username.pid.ppid
    ut_assert_eq "$ids" "$(ps -ef | awk '{printf("%s.%s.%s\n", $1, $2, $3)}' | grep "$ids")"
    ids="$(whoami).$UID.$GROUPS"
    ut_assert_eq "$ids" "$(cat /etc/passwd | awk -F ':' '{printf("%s.%s.%s\n", $1, $3, $4)}' | grep "$ids")"

    echo "running $SECONDS seconds"
}

test_bash_var_expand() {
    #
    # : means declare but not set
    #

    # use defalut
    ut_assert_eq "default" "${1-default}"   # $1 was not declared, so is default
    ut_assert_eq "" "${1}"                  # $1 was not set, so is null
    ut_assert_eq "default" "${1:-default}"  # $1 was not set, so is default

    local var=
    ut_assert_eq "" "${var-default}"          # var was declared, so is null
    ut_assert_eq "" "${var}"                  # var was not set, so is null
    ut_assert_eq "default" "${var:-default}"  # var was declared but not set, so is default
    ut_assert_eq "" "${var}"                  # var was not set, so is null
    unset var

    # set value
    ut_assert_eq "a" "${var=a}"       # var was not declared, so set var as a
    ut_assert_eq "a" "${var}"         # var is a
    ut_assert_eq "a" "${var=b}"       # var was declared on top, so set failed
    unset var

    ut_assert_eq "b" "${var:=b}"      # var was not declared and not set, so set var as b
    ut_assert_eq "b" "${var}"         # var is b
    ut_assert_eq "b" "${var:=b}"      # var was set on top, so set failed
    unset var

    # alt value
    ut_assert_eq "" "${var+hello}"        # var was not declared, so alt var
    ut_assert_eq "" "${var:+hello}"       # var was not set, so alt var
    local var=
    ut_assert_eq "hello" "${var+hello}"   # var was declared, so alt hello
    ut_assert_eq "" "${var:+hello}"       # var was not set, so alt var
    var=world
    ut_assert_eq "hello" "${var:+hello}"  # var was set, so alt hello
    ut_assert_eq "world" "${var}"         # var was set as world
    unset var

    # err msg and exit
    # ${var?"error and exit"}
    # ${var:?"error and exit"}
    local var=
    ut_assert_eq "" "${var?"use var and not exit"}"
    # ${var:?"error and exit"}
    unset var
}

test_bash_var_length() {
    local a="hello"
    ut_assert_eq "5" "${#a}"

    local b=("hello" "world")
    ut_assert_eq "5" "${#b}"        # first element length
    ut_assert_eq "2" "${#b[*]}"     # element count
    ut_assert_eq "2" "${#b[@]}"     # element count
}

test_bash_var_match() {
    # match variables tha start with "var" and be declared before (must with "=")
    local var1=1
    ut_assert_eq "var1" "${!var*}"

    local var2=
    ut_assert_eq "var1 var2" "${!var*}"

    local var3=$var1
    ut_assert_eq "var1 var2 var3" "${!var*}"

    # var4 and var5 is not declared variable (-:)
    local var4
    ut_assert_eq "var1 var2 var3" "${!var*}"
    ut_assert_eq "" "${var4+hello}"

    : var5
    ut_assert_eq "var1 var2 var3" "${!var*}"
    ut_assert_eq "" "${var5+world}"
    # unset var5

    ut_assert_eq "var1" "${!var@}"  # ?
}

test_bash_var_declare() {
    # readonly
    local VAR1="var"
    declare -r VAR1
    : VAR1="readonly var"   # error
    ut_assert_eq "var" "$VAR1"

    declare -r __VAR1
    : __VAR1="__var"    # error
    ut_assert_eq "" "$__VAR1"
    : unset __VAR1      # cannot unset: readonly variable

    # number
    local number=1
    declare -i number
    ut_assert_eq "1" "$number"
    number=two  # set failed
    ut_assert_eq "0" "$number"

    # array
    # declare -a indices

    # function
    # declare -f                    # list all declared functions
    # declare -f function_name      # list fuction whose name is the funcation_name
    __inner_function() {
        :
    }
    ut_assert_eq "__inner_function(){:}" "$(declare -f __inner_function | sed -e ':a;N;$!ba;s/\n//g' -e 's/\s\+//g')"

    # export
    # declare -x var            # var is an export variable
    # declare -x var="init"     # declare and assign
}

# Indirect reference
test_bash_var_indref() {
    # eval var1=\$$var2
    local a=b
    local b=c
    ut_assert_eq "c" "$(eval echo "\$$a")"
    ut_assert_eq "c" "${!a}"
    b=d
    ut_assert_eq "d" "$(eval echo "\$$a")"
}

# Use the ((...)) structure to operate a variable
# which can be a C language style variable
test_bash_var_calc() {
    local a=1
    a=$(( a + 1 ))
    ut_assert_eq "2" "$a"
    (( a = 1))
    ut_assert_eq "1" "$a"
    ((a=2))
    ut_assert_eq "2" "$a"
    ((a++))
    ut_assert_eq "3" "$a"
    ((a--))
    ut_assert_eq "2" "$a"
    ((++a))
    ut_assert_eq "3" "$a"
    ((--a))
    ut_assert_eq "2" "$a"
    local b=$((a++))
    ut_assert_eq "2" "$b"
    ut_assert_eq "3" "$a"
    b=$((--a))
    ut_assert_eq "2" "$b"
    ut_assert_eq "2" "$a"

    a=0
    a=$(expr $a + 3)
    ut_assert_eq "3" "$a"
    a=0
    a=$(($a+3))
    ut_assert_eq "3" "$a"
    a=0
    a=$((a+3))
    ut_assert_eq "3" "$a"
    a=0
    let a=a+3
    ut_assert_eq "3" "$a"
    a=0
    let "a = a + 3"
    ut_assert_eq "3" "$a"
}

test_bash_control_for() {
    local var=""
    for i in a b c; do
        var="$var,$i"
    done
    ut_assert_eq ",a,b,c" "$var"

    for i in "a b c"; do
        ut_assert_eq "a b c" "$i"
    done

    var=""
    for i in "a b" "c d"; do
        var="$var,$i"
    done
    ut_assert_eq ",a b,c d" "$var"

    # It may be necessary to save the original positional parameters because they are overwritten.
    # One way is to use arrays. original_params=("$@")
    var=""
    for i in "a b" "c d"; do
        set -- $i
        for j in $@; do
            var="$var,$j"
        done
    done
    ut_assert_eq ",a,b,c,d" "$var"

    # for loop ignore in, will loop $@
    __ignore_in() {
        for a; do
            echo -n "$a,"
        done
        echo
    }
    ut_assert_eq "a,b,c," "$(__ignore_in a b c)"
    ut_assert_eq "" "$(__ignore_in)"

    # use command to generate list
    local tmp="1 2 3 4"
    var=""
    for i in $(echo $tmp); do
        var="$var,$i"
    done
    ut_assert_eq ",1,2,3,4" "$var"

    # like C, using ((..))
    __like_c() {
        local count=$1
        for ((i = 1; i <= count; i++)); do
            echo -n "$i,"
        done
        echo
    }
    ut_assert_eq "1,2,3," "$(__like_c 3)"
    ut_assert_eq "" "$(__like_c)"
}

test_bash_control_while() {
    __normal() {
        local i=0
        local cnt=${1-0}
        while [ "$i" -lt "$cnt" ]; do
            echo -n "$i,"
            i=$(expr $i + 1)
        done
        echo
    }
    ut_assert_eq "0,1,2," "$(__normal 3)"
    ut_assert_eq "" "$(__normal)"

    # like C, using ((..))
    __like_c() {
        local i=0
        local cnt=${1-0}
        while (( i < cnt )); do
            echo -n "$i,"
            i=$(expr $i + 1)
        done
        echo
    }
    ut_assert_eq "0,1,2," "$(__like_c 3)"
    ut_assert_eq "" "$(__like_c)"
}

test_bash_control_until() {
    __normal() {
        local i=0
        local cnt=${1-0}
        until [ "$i" -ge "$cnt" ]; do
            echo -n "$i,"
            i=$(expr $i + 1)
        done
        echo
    }
    ut_assert_eq "0,1,2," "$(__normal 3)"
    ut_assert_eq "" "$(__normal)"

    # like C, using ((..))
    __like_c() {
        local i=0
        local cnt=${1-0}
        until (( i >= cnt )); do
            echo -n "$i,"
            i=$(expr $i + 1)
        done
        echo
    }
    ut_assert_eq "0,1,2," "$(__like_c 3)"
    ut_assert_eq "" "$(__like_c)"
}

test_bash_control_continue() {
    __normal() {
        local count=${1-0}
        for ((i = 1; i <= count; i++)); do
            local var=$(expr $i % 2)
            if [ "$var" -eq 0 ]; then
                continue
            fi
            echo -n "$i,"
        done
        echo
    }
    ut_assert_eq "1,3," "$(__normal 3)"
    ut_assert_eq "1,3," "$(__normal 4)"

    # continue N
    # this command will continue N layer loops
}

test_bash_control_break() {
    __normal() {
        local count=${1-0}
        # while :; do ... done
        # while true; do ... done
        for ((i = 1; ; i++)); do
            if [ $i -gt $count ]; then
                break
            fi
            echo -n "$i,"
        done
        echo
    }
    ut_assert_eq "1,2,3," "$(__normal 3)"

    # break N
    # this command will break N layer loops
}

test_bash_control_case() {
    __normal() {
        # POSIX style [[:xx:]]
        for a; do
            case "$a" in
                [[:lower:]]) echo -n "L$a";;
                [[:upper:]]) echo -n "U$a";;
                [0-9]) echo -n "N$a";;
                *) echo -n ".";;
            esac
        done
        echo
    }
    ut_assert_eq "La.UP..N1" "$(__normal a % P . ^ 1)"

    __simple_menu() {
        local m="$1"
        case "$m" in
            "L"|"l")
                echo "Large"
                ;;
            "M"|"m")
                echo "Middle"
                ;;
            S*|"s")
                echo "Small"
                ;;
            *)
                echo "None"
                ;;
        esac
    }
    ut_assert_eq "Large" "$(__simple_menu L)"
    ut_assert_eq "Large" "$(__simple_menu l)"
    ut_assert_eq "Small" "$(__simple_menu S)"
    ut_assert_eq "Small" "$(__simple_menu Small)"
    ut_assert_eq "Small" "$(__simple_menu Supper)"
    ut_assert_eq "None" "$(__simple_menu a)"
}

test_bash_control_select() {
    __normal() {
        select i in "gauss" "euler" "maminjie"; do
            echo "$i"
            break
        done
    }
    # ut_assert_eq "maminjie" "$(__normal)"  # hint 3
}

# eval arg1 [arg2] ... [argN]
test_bash_cmd_eval() {
    # rot13 is to divide 26 letters from the middle
    # Two and a half, 13 each
    setvar_rot_13() {
        local varname=$1 varvalue=$2
        eval $varname='$(echo "$varvalue" | tr a-z n-za-m)'
    }
    local var=
    setvar_rot_13 var "foobar"
    ut_assert_eq "sbbone" "$var"
    setvar_rot_13 var "sbbone"
    ut_assert_eq "foobar" "$var"
}

# set `command`
# set -- $var
# set --

test_bash_cmd_export() {
    export __abc=(a b)
    ut_assert_eq "a" "${__abc[0]}"  # not (a b) ?
    unset __abc
    __abc=(c d)
    export __abc
    ut_assert_eq "c" "${__abc[0]}"
    unset __abc
}

test_bash_cmd_getopts() {
    __normal() {
        # first : Can shield the error when e does not take parameter
        while getopts ":ab:c" opt; do
            case $opt in
                a) echo -n "a-True,";;
                b) echo -n "$OPTARG,";;
                c) echo -n "c-True,";;
            esac
        done
        shift $(($OPTIND - 1))
        echo -n "$@"
        echo
    }
    ut_assert_eq "a-True,body," "$(__normal -a -b body -d)"
    ut_assert_eq "c-True,hello,world" "$(__normal -c -b hello world)"
    ut_assert_eq "err -a -b" "$(__normal err -a -b)"
    ut_assert_eq "a-True,err -b" "$(__normal -a err -b)"
}

test_bash_cmd_caller() {
    __normal() {
        caller 0
    }
    # lineno callername filename
    ut_assert_eq "$LINENO $FUNCNAME $BASH_SOURCE" "$(__normal)"
}

test_bash_cmd_miscs() {
    # "xargs -n NN" NN is used to limit the number of parameters passed in each time
    ut_assert_eq "2" "$(echo "1 2 3 4" | xargs -n 2 echo | wc -l)"

    ut_assert_eq "1 3" "$(echo "1 2 3 4" | cut -d" " -f1,3)"
    # cut -d ' ' -f2,3 filename == awk -F'[ ]' '{ print $2, $3 }' filename

    ut_assert_eq "5" "$(seq 5 | wc -l)"
    ut_assert_eq "1:2:3:4:5" "$(seq -s : 5)"
    ut_assert_eq "1:3:5" "$(seq -s : 1 2 5)"
}

test_bash_here_document() {
cat << EOF
This is bash script
here document
EOF

: <<DOCUMENTATIONXX
    comment
    multi
    lines
DOCUMENTATIONXX

    # here string
    # COMMAND <<< $WORD
    # $WORD will be expanded and sent to stdin of COMMAND
    local a=
    read a <<< "hello"
    ut_assert_eq "hello" "$a"
}

: << EOF
POSIX class: [:class:]
[:alnum:] = A-Za-z0-9
[:alpha:] = A-Za-z
[:blank:] = space or tab
[:cntrl:] = control char
[:digit:] = 0-9
[:graph:] = ASCII 33-126
[:lower:] = a-z
[:print:] = ASCII 33-126 and space
[:space:] = space or tab
[:upper:] = A-Z
[:xdigit:] = 0-9A-Fa-f
EOF
test_bash_re() {
    local var="hello world, i am maminjie"

    ut_assert_eq "rl" "$(echo "$var" | grep -oE "rl*")"
    ut_assert_eq "ll\nl" "$(echo "$var" | grep -oE "l*")"

    ut_assert_eq "ll\nld" "$(echo "$var" | grep -oE "l.")"

    ut_assert_eq "h" "$(echo "$var" | grep -oE "^h")"
    ut_assert_eq "" "$(echo "$var" | grep -oE "^w")"

    ut_assert_eq "e" "$(echo "$var" | grep -oE "e$")"
    ut_assert_eq "" "$(echo "$var" | grep -oE "m$")"

    ut_assert_eq "o\no\ni\ni\ni" "$(echo "$var" | grep -oE "[oi]")"
    ut_assert_eq "h\ni\ni\nj\ni" "$(echo "$var" | grep -oE "[h-k]")"
    ut_assert_eq "w\na\na" "$(echo "$var" | grep -oE "[^c-r ,]")"

    ut_assert_eq "" "$(echo "$var" | grep -oE "<i>")"
    ut_assert_eq "i" "$(echo "$var" | grep -oE "\<i\>")"

    ut_assert_eq "o\no" "$(echo "$var" | grep -oE "o?")"
    ut_assert_eq "r" "$(echo "$var" | grep -oE "r?")"
    ut_assert_eq "" "$(echo "$var" | grep -oE "t?")"
    ut_assert_eq "i\nin\ni" "$(echo "$var" | grep -oE "in?")"
    ut_assert_eq "el\ne" "$(echo "$var" | grep -oE "el?")"

    ut_assert_eq "ell" "$(echo "$var" | grep -oE "el+")"

    ut_assert_eq "ll" "$(echo "$var" | grep -oE "[lom]{2}")"
    ut_assert_eq "llo" "$(echo "$var" | grep -oE "[lom]{3}")"
    ut_assert_eq "" "$(echo "$var" | grep -oE "[lom]{5}")"
    ut_assert_eq "ll\nnj" "$(echo "$var" | grep -oE "[j-p]{2}")"

    ut_assert_eq "lo\nwo" "$(echo "$var" | grep -oE "(l|w)o")"

    ut_assert_eq "e\nd\na\na\ne" "$(echo "$var" | grep -oE "[[:xdigit:]]")"
}

test_bash_function() {
    function __f1 {
        echo "f1"
    }

    function __f2() {
        echo "f2"
    }

    __f3() {
        echo "f3"
    }
    ut_assert_eq "f1" "$(__f1)"
    ut_assert_eq "f2" "$(__f2)"
    ut_assert_eq "f3" "$(__f3)"

    # indirect reference
    __f_ir1() {
        echo "$1"
    }
    local a=b
    local b=c
    ut_assert_eq "b" "$(__f_ir1 "$a")"
    ut_assert_eq "b" "$(__f_ir1 "${a}")"
    ut_assert_eq "c" "$(__f_ir1 "${!a}")"
    b=d
    ut_assert_eq "b" "$(__f_ir1 "${a}")"
    ut_assert_eq "d" "$(__f_ir1 "${!a}")"

    # dereference
    __dereference_1() {
        local _p=\$"$1"
        echo $_p
        eval $1=\"w\"
    }
    a=b
    ut_assert_eq "b" "$a"
    ut_assert_eq "\$a" "$(__dereference_1 a)"
    ut_assert_eq "b" "$a" # no modified

    __dereference_2() {
        eval "$1=\"w\""
    }
    __dereference_2 a
    ut_assert_eq "w" "$a" # modified

    __dereference_3() {
        eval 'echo "$'$1'"'
        eval echo "\$$1"
    }
    a=b
    ut_assert_eq "b\nb" "$(__dereference_3 a)"

    # return
    __max() {
        if [ "$1" -gt "$2" ]; then
            return $1
        else
            return $2
        fi
    }
    __max 12 21
    ut_assert_eq "21" "$?"

    # return string
    __return_str() {
        if [ -z "$1" ]; then
            REPLY="none"
            return 1
        else
            REPLY="$1"
            return 0
        fi
    }
    __test_return_str() {
        if __return_str "$a"; then
            ut_assert_eq "$a" "$REPLY"
            echo "$a"
        else
            ut_assert_eq "none" "$REPLY"
            echo "none"
        fi
    }
    a=
    ut_assert_eq "none" "$(__test_return_str)"
    a=b
    ut_assert_eq "b" "$(__test_return_str)"
}

test_bash_list_structure() {
    __f1() {
        [[ ! -z "$1" ]] && echo "$1" && [[ ! -z "$2" ]] && echo "$2"
    }
    ut_assert_eq "a" "$(__f1 a)"
    ut_assert_eq "a\nb" "$(__f1 a b)"
    ut_assert_eq "" "$(__f1 "" b)"

    __f2() {
        ([[ ! -z "$1" ]] && echo "$1") || ([[ ! -z "$2" ]] && echo "$2")
    }
    ut_assert_eq "a" "$(__f2 a)"
    ut_assert_eq "a" "$(__f2 a b)"
    ut_assert_eq "b" "$(__f2 "" b)"
}

test_bash_array() {
    local a1=(1 2 3 4)
    ut_assert_eq "4" "${#a1[@]}"
    ut_assert_eq "4" "${#a1[*]}"
    ut_assert_eq "1" "${a1[0]}"
    ut_assert_eq "4" "${a1[3]}"
    ut_assert_eq "" "${a1[4]}"

    local a2=([1]=1 [3]=3 [4]=4)
    ut_assert_eq "3" "${#a2[@]}"
    ut_assert_eq "3" "${#a2[*]}"
    ut_assert_eq "" "${a2[0]}"
    ut_assert_eq "3" "${a2[3]}"
    ut_assert_eq "4" "${a2[4]}"

    local a3=(zero one two three)
    ut_assert_eq "zero" "${a3[0]}"
    ut_assert_eq "zero" "${a3:0}"
    ut_assert_eq "ero" "${a3:1}"
    ut_assert_eq "4" "${#a3[0]}"
    ut_assert_eq "4" "${#a3}"
    ut_assert_eq "3" "${#a3[1]}"
    ut_assert_eq "4" "${#a3[*]}"

    ut_assert_eq "zero one two three" "$(echo ${a3[@]:0})"
    ut_assert_eq "one two three" "$(echo ${a3[@]:1})"
    ut_assert_eq "one two" "$(echo ${a3[@]:1:2})"
    # others string operatation ...

    # expand
    a3=(${a3[@]} four)
    ut_assert_eq "four" "${a3[4]}"
    a3[${#a3[*]}]=five
    ut_assert_eq "five" "${a3[5]}"
    unset a3[${#a3[*]}-1]
    ut_assert_eq "" "${a3[5]}"

    local a4=(${a3[@]:1:2})
    ut_assert_eq "one two" "${a4[*]}"

    # Array hole
    local a5=(${a2[@]})
    ut_assert_eq "3" "${#a5[@]}"
    ut_assert_eq "3" "${#a5[*]}"
    ut_assert_eq "1" "${a5[0]}"
    ut_assert_eq "3" "${a5[1]}"
    ut_assert_eq "4" "${a5[2]}"
    ut_assert_eq "" "${a5[3]}"
    ut_assert_eq "" "${a5[4]}"
}

test_bash_sed() {
    local var="abcacbbac
bcacabcba"

    # s
    # n
    ut_assert_eq "a-cacbbac\n-cacabcba" "$(echo "$var" | sed 's/b/-/1')"  # n flag
    ut_assert_eq "abcac-bac\nbcaca-cba" "$(echo "$var" | sed 's/b/-/2')"
    # g
    ut_assert_eq "a-cacbbac\n-cacabcba" "$(echo "$var" | sed 's/b/-/')"
    ut_assert_eq "a-cac--ac\n-caca-c-a" "$(echo "$var" | sed 's/b/-/g')"
    # p
    ut_assert_eq "abcac--ac\nabcac--ac\nbcacabcba" "$(echo "$var" | sed 's/bb/--/p')"
    ut_assert_eq "abcac--ac" "$(echo "$var" | sed -n 's/bb/--/p')"
    ut_assert_eq "abcacbbac\nabcac--ac" "$(echo "$var" | sed -n '/bb/{p;s/bb/--/p;}')"
    ut_assert_eq "abc--bb--\nbcacabcba" "$(echo "$var" | sed '/bb/s/ac/--/g')"

    # q
    ut_assert_eq "abcacbbac" "$(echo "$var" | sed '/b/q')"

var="a
b
c
d"
    # d
    ut_assert_eq "" "$(echo "$var" | sed 'd')"
    ut_assert_eq "b\nc\nd" "$(echo "$var" | sed '1d')"
    ut_assert_eq "a\nc\nd" "$(echo "$var" | sed '2d')"
    ut_assert_eq "a\nd" "$(echo "$var" | sed '2,3d')"
    # ut_assert_eq "d" "$(echo "$var" | sed '/1/,/3/d')"
    ut_assert_eq "a" "$(echo "$var" | sed '2,$d')"
    # i, a
    ut_assert_eq "a\nb\nx\nc\nd" "$(echo "$var" | sed '3i\x')"
    ut_assert_eq "a\nb\nc\nx\nd" "$(echo "$var" | sed '3a\x')"
    ut_assert_eq "xy\na\nb\nc\nd" "$(echo "$var" | sed '1i\x\y')"
    ut_assert_eq "x\ny\na\nb\nc\nd" "$(echo "$var" | sed '1i\x\\ny')"
    # c
    ut_assert_eq "a\nx\nc\nd" "$(echo "$var" | sed '2c\x')"
    ut_assert_eq "a\nx\nc\nd" "$(echo "$var" | sed '/b/c\x')"
    # y
    ut_assert_eq "x\ny\nc\nd" "$(echo "$var" | sed 'y/ab/xy/')"
    ut_assert_eq "x\ny\nc\nd" "$(echo "$var" | sed 'y/abb/xyz/')"
    # q
    ut_assert_eq "a\nb" "$(echo "$var" | sed '2q')"

var="a1
b2
33"
    # &
    ut_assert_eq "<a1>\n<b2>\n33" "$(echo "$var" | sed '/[a-z][0-9]/{s//\<&\>/}')"
    ut_assert_eq "aa1\nba2\na3b3" "$(echo "$var" | sed '/[0-9]/{s//a&/1;s//b&/2;}')"
}
