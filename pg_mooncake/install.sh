#!/bin/bash

set -eux

docker run -d --name pg_mooncake -p 5433:5432 -e POSTGRES_HOST_AUTH_METHOD=trust \
    -v ../split_10M:/tmp/split_10M \
    -v ../users_10M.csv:/tmp/users_10M.csv \
    mooncakelabs/pg_mooncake:17-v0.1.0

sleep 5
psql postgres://postgres:pg_mooncake@localhost:5433/postgres -f create.sql

# COPY 99997497
# Time: 576219.151 ms (09:36.219)

psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t -c 'CREATE DATABASE test'