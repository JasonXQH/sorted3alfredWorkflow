#!/bin/bash

# 检查参数数量
#!/bin/bash

# Check the number of parameters
if [ $# -lt 1 ]; then
    echo "Insufficient parameters. Usage: script.sh <title> [date] [time] [duration]"
    exit 1
fi

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
    else
        duration="${params[i]}"
    fi
done

build_url
 
# open -g ${url}