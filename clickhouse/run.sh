#!/bin/bash

TRIES=3
QUERY_NUM=1

QUERY_FILE=${1:-queries.sql}

cat "$QUERY_FILE" | while read -r query; do
    [ -z "$FQDN" ] && sync
    [ -z "$FQDN" ] && echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null

    echo -n "["
    for i in $(seq 1 $TRIES); do
        RES=$(clickhouse-client --host "${FQDN:=localhost}" --password "${PASSWORD:=}" ${PASSWORD:+--secure} --time --format=Null --query="$query" --progress 0 2>&1 ||:)
        [[ "$?" == "0" ]] && echo -n "${RES}" || echo -n "null"
        [[ "$i" != $TRIES ]] && echo -n ", "

        echo "Time: ${RES##*Time: } ms"
    done
    echo "],"

    QUERY_NUM=$((QUERY_NUM + 1))
done