CREATE TABLE transactions
(
    "id" BIGINT,
    "user_id" BIGINT NOT NULL,
    "amount" INT NOT NULL,
    "type" TEXT NOT NULL,
    "country_code" TEXT NOT NULL,
    "platform" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL
);

CREATE TABLE users
(
    "id" BIGINT PRIMARY KEY,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "email_verified_at" TIMESTAMPTZ,
    "password" TEXT NOT NULL,
    "country_code" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL,
    "remember_token" TEXT,
    "created_at" TIMESTAMPTZ NOT NULL,
    "updated_at" TIMESTAMPTZ NOT NULL
);


SELECT create_hypertable('transactions', by_range('created_at', INTERVAL '3 months'));
ALTER TABLE transactions SET (timescaledb.enable_columnstore = true);
-- ALTER TABLE transactions SET (timescaledb.compress_segmentby = 'user_id');
-- CALL add_columnstore_policy('transactions', INTERVAL '1 day');

