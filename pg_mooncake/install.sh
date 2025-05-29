#!/bin/bash

set -eux

# Get the absolute path of the parent directory
PARENT_DIR="$(cd .. && pwd)"

docker run -d --name pg_mooncake -p 5433:5432 -e POSTGRES_HOST_AUTH_METHOD=trust \
    -v "${PARENT_DIR}/split_10M:/tmp/split_10M" \
    -v "${PARENT_DIR}/users_10M.csv:/tmp/users_10M.csv" \
    -v "${PARENT_DIR}/transactions_10M.csv:/tmp/transactions_10M.csv" \
    -v "${PARENT_DIR}/transactions-10m-2.parquet:/tmp/transactions-10m-2.parquet" \
    -v "${PARENT_DIR}/users-10m.parquet:/tmp/users-10m.parquet" \
    -v /proc/sys/vm:/proc/sys/vm \
    mooncakelabs/pg_mooncake

sleep 5
psql postgres://postgres:pg_mooncake@localhost:5433/postgres -f create.sql

# COPY 99997497
# Time: 576219.151 ms (09:36.219)

psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t -c 'CREATE DATABASE test'