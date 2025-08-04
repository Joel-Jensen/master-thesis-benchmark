#!/bin/bash

set -eux

threads=$(nproc)
cpus=$((threads > 1 ? threads / 2 : 1))

psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t < create.sql

psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t -c "INSERT INTO transactions SELECT r['id']::BIGINT, r['user_id']::BIGINT, r['amount']::INT, r['type'], r['country_code'], r['platform'], r['created_at']::TIMESTAMP FROM mooncake.read_csv('/tmp/transactions_10M.csv', AUTO_DETECT=TRUE) r"
psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t -c "\\copy users (id, name, email, email_verified_at, password, country_code, is_active, remember_token, created_at, updated_at) FROM '../users_10M.csv' DELIMITER ','"
#time psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t <index.sql

# This is like VACUUM ANALYZE but for pg_mooncake
# time psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t -c 'UPDATE transactions SET id=id'

./benchmark.sh