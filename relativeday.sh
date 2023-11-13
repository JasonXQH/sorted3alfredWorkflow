#!/bin/bash

# Check the number of parameters
if [ $# -lt 1 ]; then
    echo "Insufficient parameters. Usage: script.sh <title> [date] [time] [duration]"
    exit 1
fi
# Function to parse relative dates
parse_relative_date() {
    local relative_date=$1
    local day_diff
    local target_day

    today=$(date +'%u') # 获取今天是星期几（1表示星期一，7表示星期天）

    case $relative_date in

        "明天"|"tom")
            date=$(date -v +1d +'%Y-%m-%d')
            return
            ;;

        "后天")
            date=$(date -v +2d +'%Y-%m-%d')
            return
            exit 1
            ;;
        "星期一" | "礼拜一" | "mon")
            target_day=1
            ;;
        "星期二"| "礼拜二" | "tue")
            target_day=2
            ;;
        "星期三"| "礼拜三" | "wed")
            target_day=3
            ;;
        "星期四"| "礼拜四" | "thu")
            target_day=4
            ;;
        "星期五"| "礼拜五" | "fri")
            target_day=5
            ;;
        "星期六"| "礼拜六" | "sat")
            target_day=6
            ;;
        "星期天" | "星期日" | "sun")
            target_day=7
            ;;
        *)
            echo "Unknown relative date: $relative_date"
            exit 1
            ;;
    esac

    day_diff=$((target_day - today)) # 计算差距

    if [ $day_diff -le 0 ]; then
        day_diff=$((7 + day_diff))
    fi

    date=$(date -v +"$day_diff"d +'%Y-%m-%d')
}


# Function to format the time
format_time() {
    local t=$1
    if [[ $t =~ ^[0-9]{1,2}$ ]]; then
        time="${t}:00"
    else
        time=$(echo "$t" | sed 's/：/:/g')
    fi
}

# Function to format the date
format_date() {
    local d=$1
    if [[ $d =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        date="$d"
    elif [[ $d =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}$ ]]; then
        date="${d// /T}"
    fi
}

# Function to build the URL
build_url() {
    url="sorted://x-callback-url/add?title=${title}"

    if [ -n "$date" ]; then
        url="${url}&date=${date}"
    fi

    if [ -n "$time" ]; then
        url="${url}&time=${time}"
    fi
    if [ -n "$duration" ]; then
        url="${url}&duration=${duration}"
    fi
    echo ${url}
}



split_params() {
    IFS=$1 read -r -a params <<< "$2"
}
# 将输入的参数按分号分割
case $1 in
    *";"*)
        split_params ';' "$1"
        ;;
    *"；"*)
        split_params '；' "$1"
        ;;
    *","*)
        split_params ',' "$1"
        ;;
    *)
        split_params ' ' "$1"
        ;;
esac


title="${params[0]}"
date=""
time=""
duration=""


for (( i=1; i<${#params[@]}; i++ )); do
    if [[ ${params[i]} =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ || ${params[i]} =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}$ ]]; then
        format_date "${params[i]}"
    elif [[ ${params[i]} =~ ^[0-9]{1,2}(:00)?$ ]]; then
        format_time "${params[i]}"
    elif [[ ${params[i]} =~ ^[0-9]+$ ]]; then
        duration="${params[i]}"
    elif [[ ${params[i]} =~ ^[0-9]+(\.[0-9]+)?h$ ]]; then
        hours=$(echo "${params[i]}" | sed 's/h//')
        duration=$(echo "$hours * 60" | bc -l | awk -F '.' '{print $1}')
    else
        parse_relative_date "${params[i]}"
        if [ -z "$date" ]; then
            format_date "$day_of_week"
        fi
    fi
done


build_url
open -g ${url}