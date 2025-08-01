
CREATE TABLE users
(
    "id" BIGINT PRIMARY KEY,
    "name" varchar(255) NOT NULL,
    "email" varchar(255) NOT NULL,
    "email_verified_at" timestamp(0),
    "password" varchar(255) NOT NULL,
    "country_code" varchar(255) NOT NULL,
    "is_active" BOOLEAN NOT NULL,
    "remember_token" varchar(100),
    "created_at" timestamp(0) NOT NULL,
    "updated_at" timestamp(0) NOT NULL
);

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


-- 2023 Q1
CREATE TABLE transactions_y2023q1 PARTITION OF transactions
    FOR VALUES FROM ('2023-01-01') TO ('2023-04-01');

-- 2023 Q2
CREATE TABLE transactions_y2023q2 PARTITION OF transactions
    FOR VALUES FROM ('2023-04-01') TO ('2023-07-01');

-- 2023 Q3
CREATE TABLE transactions_y2023q3 PARTITION OF transactions
    FOR VALUES FROM ('2023-07-01') TO ('2023-10-01');

-- 2023 Q4
CREATE TABLE transactions_y2023q4 PARTITION OF transactions
    FOR VALUES FROM ('2023-10-01') TO ('2024-01-01');

-- 2024 Q1
CREATE TABLE transactions_y2024q1 PARTITION OF transactions
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');

-- 2024 Q2
CREATE TABLE transactions_y2024q2 PARTITION OF transactions
    FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');

-- 2024 Q3

CREATE TABLE transactions_y2024q3 PARTITION OF transactions
    FOR VALUES FROM ('2024-07-01') TO ('2024-10-01');

-- 2024 Q4
CREATE TABLE transactions_y2024q4 PARTITION OF transactions
    FOR VALUES FROM ('2024-10-01') TO ('2025-01-01');

-- 2025 Q1
CREATE TABLE transactions_y2025q1 PARTITION OF transactions
    FOR VALUES FROM ('2025-01-01') TO ('2025-04-01');

-- Add constraints for each partition
ALTER TABLE transactions_y2023q1 ADD CONSTRAINT transactions_y2023q1_check
    CHECK (created_at >= '2023-01-01' AND created_at < '2023-04-01');

ALTER TABLE transactions_y2023q2 ADD CONSTRAINT transactions_y2023q2_check
    CHECK (created_at >= '2023-04-01' AND created_at < '2023-07-01');

ALTER TABLE transactions_y2023q3 ADD CONSTRAINT transactions_y2023q3_check
    CHECK (created_at >= '2023-07-01' AND created_at < '2023-10-01');

ALTER TABLE transactions_y2023q4 ADD CONSTRAINT transactions_y2023q4_check
    CHECK (created_at >= '2023-10-01' AND created_at < '2024-01-01');

ALTER TABLE transactions_y2024q1 ADD CONSTRAINT transactions_y2024q1_check
    CHECK (created_at >= '2024-01-01' AND created_at < '2024-04-01');

ALTER TABLE transactions_y2024q2 ADD CONSTRAINT transactions_y2024q2_check
    CHECK (created_at >= '2024-04-01' AND created_at < '2024-07-01');

ALTER TABLE transactions_y2024q3 ADD CONSTRAINT transactions_y2024q3_check
    CHECK (created_at >= '2024-07-01' AND created_at < '2024-10-01');

ALTER TABLE transactions_y2024q4 ADD CONSTRAINT transactions_y2024q4_check
    CHECK (created_at >= '2024-10-01' AND created_at < '2025-01-01');

ALTER TABLE transactions_y2025q1 ADD CONSTRAINT transactions_y2025q1_check
    CHECK (created_at >= '2025-01-01' AND created_at < '2025-04-01');

CREATE INDEX user_id on transactions (user_id);
CREATE INDEX type on transactions (type);
CREATE INDEX created_at on transactions USING BRIN (created_at);

/*
CREATE TABLE transactions_y2023 PARTITION OF transactions
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE transactions_y2024 PARTITION OF transactions
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

ALTER TABLE transactions_y2023 ADD CONSTRAINT transactions_y2023_check
    CHECK (created_at >= '2023-01-01' AND created_at < '2024-01-01');

ALTER TABLE transactions_y2024 ADD CONSTRAINT transactions_y2024_check
    CHECK (created_at >= '2024-01-01' AND created_at < '2025-01-01');
*/