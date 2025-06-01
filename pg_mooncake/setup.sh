#!/bin/bash

set -eux

psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t -c 'DROP DATABASE test WITH (FORCE)'
psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t -c 'CREATE DATABASE test'
psql postgres://postgres:pg_mooncake@localhost:5433/postgres test -t < create.sql

threads=$(nproc)
cpus=$((threads > 1 ? threads / 2 : 1))

psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t -c "INSERT INTO transactions SELECT id, user_id, amount, type, country_code, platform, created_at::timestamp AS created_at FROM mooncake.read_csv('/tmp/transactions_10M.csv') as (id BIGINT, user_id BIGINT, amount INT, type VARCHAR, country_code VARCHAR, platform VARCHAR, created_at TEXT)"
psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t -c "\\copy users (id, name, email, email_verified_at, password, country_code, is_active, remember_token, created_at, updated_at) FROM '../users_10M.csv' DELIMITER ','"
#time psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t <index.sql

# This is like VACUUM ANALYZE but for pg_mooncake
time psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t -c 'UPDATE transactions SET id=id'

./benchmark.sh