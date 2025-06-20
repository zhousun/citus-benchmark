DROP EXTENSION IF EXISTS pg_mooncake CASCADE;
CREATE extension pg_mooncake;

CREATE OR REPLACE FUNCTION create_all_columnar_tables(target_schema TEXT DEFAULT 'public')
RETURNS void AS $$
DECLARE
    rec RECORD;
    row_table TEXT;
    col_table TEXT;
BEGIN
    FOR rec IN
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_schema = target_schema
          AND table_type = 'BASE TABLE'
    LOOP
        col_table := format('mooncake_cs_%s', rec.table_name);
        BEGIN
            CALL mooncake.create_table(col_table, rec.table_name);
        EXCEPTION WHEN OTHERS THEN
            -- Do nothing
            NULL;
        END;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
