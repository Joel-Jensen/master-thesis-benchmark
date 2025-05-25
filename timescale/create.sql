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

SELECT create_hypertable('transactions', by_range('created_at', INTERVAL '3 months'));
ALTER TABLE transactions SET (timescaledb.enable_columnstore = true);
-- ALTER TABLE transactions SET (timescaledb.compress_segmentby = 'user_id');
-- CALL add_columnstore_policy('transactions', INTERVAL '1 day');

-- Convert all chunks to columnstore
DO $$
DECLARE
    chunk RECORD;
BEGIN
    FOR chunk IN
        SELECT format('_timescaledb_internal.%I', chunk_name) AS chunk_name
        FROM timescaledb_information.chunks
        WHERE hypertable_name = 'transactions'
          AND NOT is_compressed
    LOOP
        RAISE NOTICE 'Converting chunk %', chunk.chunk_name;
        EXECUTE format('CALL convert_to_columnstore(%L)', chunk.chunk_name);
    END LOOP;
END
$$;
