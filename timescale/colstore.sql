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
