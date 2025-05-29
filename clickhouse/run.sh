#!/bin/bash

TRIES=3
QUERY_NUM=1

QUERY_FILE=${1:-queries.sql}

cat "$QUERY_FILE" | while read -r query; do
    [ -z "$FQDN" ] && sync
    [ -z "$FQDN" ] && echo 3 | sudo /proc/sys/vm/drop_caches >/dev/null

    echo "$query"
    for i in $(seq 1 $TRIES); do
        RES=$(clickhouse-client --host "${FQDN:=localhost}" --password "${PASSWORD:=}" ${PASSWORD:+--secure} --time --format=Null --query="$query" --progress 0 2>&1 ||:)
        echo -n "Time: $(echo "${RES} * 1000" | bc) ms"
        [[ "$i" != $TRIES ]] && echo ", "
    done
    echo "----------------------------------------"

    QUERY_NUM=$((QUERY_NUM + 1))
done