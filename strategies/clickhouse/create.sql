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
ORDER BY (toDate(created_at))