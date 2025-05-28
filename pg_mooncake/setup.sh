#!/bin/bash

set -eux

psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t -c 'DROP DATABASE test WITH (FORCE)'
psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t -c 'CREATE DATABASE test'
psql postgres://postgres:pg_mooncake@localhost:5433/postgres test -t < create.sql

threads=$(nproc)
cpus=$((threads > 1 ? threads / 2 : 1))

psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t -c "INSERT INTO transactions SELECT id, user_id, amount, type, country_code, platform, 'epoch'::timestamp + (created_at || 'second')::interval created_at FROM mooncake.read_parquet('/tmp/transactions-10m-2.parquet') as(id BIGINT, user_id BIGINT, amount INT, type VARCHAR, country_code VARCHAR, platform VARCHAR, created_at BIGINT)"
psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t -c "INSERT INTO users SELECT id, name, email, 'epoch'::timestamp + (email_verified_at || 'second')::interval email_verified_at, password, country_code, is_active, remember_token, 'epoch'::timestamp + (created_at || 'second')::interval created_at, 'epoch'::timestamp + (updated_at || 'second')::interval updated_at FROM mooncake.read_parquet('/tmp/users-10m.parquet') as (id BIGINT, name VARCHAR, email VARCHAR, email_verified_at BIGINT, password VARCHAR, country_code VARCHAR, is_active BOOLEAN, remember_token VARCHAR, created_at BIGINT, updated_at BIGINT)"
#time psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t <index.sql

time psql postgres://postgres:pg_mooncake@localhost:5433/postgres -t -c 'VACUUM ANALYZE transactions'

./benchmark.sh