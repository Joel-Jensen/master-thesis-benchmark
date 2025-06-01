#!/bin/bash

TRIES=3
QUERY_NUM=1

QUERY_FILE=${1:-queries.sql}

cat "$QUERY_FILE" | while read -r query; do
    [ -z "$FQDN" ] && sync
    [ -z "$FQDN" ] && sudo tee /proc/sys/vm/drop_caches >/dev/null <<< "3"

    echo "$query"
    for i in $(seq 1 $TRIES); do
        echo "Run $i:"
        RES=$(clickhouse-client --host "${FQDN:=localhost}" --password "${PASSWORD:=}" ${PASSWORD:+--secure} --time --query="$query" --progress 0 2>&1)
        echo "Time: $(echo "$(echo "$RES" | grep -o -P '^\d+\.\d+$') * 1000" | bc) ms"
    done
    echo ""
    echo "----------------------------------------"

    QUERY_NUM=$((QUERY_NUM + 1))
done