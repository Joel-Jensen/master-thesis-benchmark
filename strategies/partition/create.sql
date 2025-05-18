CREATE TABLE transactions
(
    "id" BIGINT NOT NULL,
    "user_id" BIGINT NOT NULL,
    "amount" INT NOT NULL,
    "type" varchar(255) NOT NULL,
    "country_code" varchar(255) NOT NULL,
    "platform" varchar(255) NOT NULL,
    "created_at" timestamp(0) NOT NULL,
    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

CREATE TABLE transactions_y2023 PARTITION OF transactions
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE transactions_y2024 PARTITION OF transactions
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

ALTER TABLE transactions_y2023 ADD CONSTRAINT transactions_y2023_check
    CHECK (created_at >= '2023-01-01' AND created_at < '2024-01-01');

ALTER TABLE transactions_y2024 ADD CONSTRAINT transactions_y2024_check
    CHECK (created_at >= '2024-01-01' AND created_at < '2025-01-01');