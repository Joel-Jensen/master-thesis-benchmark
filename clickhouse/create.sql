CREATE OR REPLACE TABLE transactions
(
    id UInt64,
    user_id UInt64,
    amount Int32,
    type String,
    country_code String,
    platform String,
    created_at DateTime
)
ENGINE = MergeTree()
ORDER BY (toDate(created_at));

CREATE TABLE users
(
    id UInt64,
    name String,
    email String,
    email_verified_at DateTime,
    password String,
    country_code String,
    is_active Boolean,
    remember_token String,
    created_at DateTime,
    updated_at DateTime
)
ENGINE = MergeTree()
ORDER BY (id)