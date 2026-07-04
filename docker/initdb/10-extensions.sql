CREATE EXTENSION IF NOT EXISTS pg_duckdb;
CREATE EXTENSION modak;

-- DuckDB-side extensions for reading Iceberg tables over S3.
SELECT duckdb.install_extension('httpfs');
SELECT duckdb.install_extension('iceberg');

-- DuckDB parallel heap scans deadlock against PG parallel workers on mixed plans.
ALTER SYSTEM SET duckdb.max_workers_per_postgres_scan = 0;

-- Transparent UPDATE/DELETE of cold rows spools the lake scan through a
-- nested statement (modak_lake_rows), which pg_duckdb gates behind this GUC.
ALTER SYSTEM SET duckdb.unsafe_allow_execution_inside_functions = 'on';

-- Order matters: pg_duckdb first, so modak's planner hook runs first.
-- List GUC: separate quoted items, or ALTER SYSTEM stores one bogus name.
ALTER SYSTEM SET shared_preload_libraries = 'pg_duckdb', 'modak';

-- Mirrored tables stream changes over logical replication (pgoutput).
ALTER SYSTEM SET wal_level = 'logical';
