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
        row_table := format('%I.%I', rec.table_schema, rec.table_name);
        col_table := format('Mooncake_CS_%s', rec.table_name);
        BEGIN
            CALL create_mooncake_table(col_table, row_table);
        EXCEPTION WHEN OTHERS THEN
            -- Do nothing
            NULL;
        END;
    END LOOP;
END;
$$ LANGUAGE plpgsql;