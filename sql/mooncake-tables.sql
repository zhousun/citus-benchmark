DROP EXTENSION IF EXISTS pg_mooncake CASCADE;
CREATE extension pg_mooncake;
CREATE FUNCTION call_mooncake_on_create() RETURNS event_trigger AS $$
DECLARE
  cmd record;
  tbl_name text;
  schema_name text;
  full_name text;
  cs_table_name text;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag = 'CREATE TABLE' THEN
      -- Parse 'schema.table' into schema and table names
      full_name := cmd.object_identity;
      schema_name := split_part(full_name, '.', 1);
      tbl_name := split_part(full_name, '.', 2);

      -- Skip tables starting with 'CS'
      IF tbl_name LIKE 'Mooncake_CS_%' THEN
        CONTINUE;
      END IF;

      -- Build CS table name and call procedure
      cs_table_name := format('Mooncake_CS_%s', tbl_name);
      CALL create_mooncake_table(cs_table_name, tbl_name);
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE EVENT TRIGGER mooncake_create_hook
  ON ddl_command_end
  WHEN TAG IN ('CREATE TABLE')
  EXECUTE FUNCTION call_mooncake_on_create();
