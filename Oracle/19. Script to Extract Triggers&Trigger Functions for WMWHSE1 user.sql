-- The query should be run at Oracle

-- Script to extract Triggers & Trigger Functions belongs to WMWHSE1 role to execute on Postgresq1

DECLARE
  -- Variables to hold trigger details
  v_trigger_name VARCHAR2(100);
  v_table_name VARCHAR2(100);
  v_owner VARCHAR2(100);
  v_trigger_body CLOB;  -- Use CLOB to hold the LONG column's contents
  v_trigger_event VARCHAR2(100);
  v_create_function_sql CLOB;
  v_create_trigger_sql CLOB;
BEGIN
  -- Cursor to loop through the triggers
  FOR rec IN (
    SELECT trigger_name, table_name, triggering_event, trigger_body, owner
    FROM all_triggers
    WHERE owner = 'WMWHSE1'  ORDER BY TRIGGER_NAME-- Replace with your schema name
  ) LOOP
    -- Extract the trigger body into a CLOB variable
    v_trigger_name := rec.trigger_name;
    v_table_name := rec.table_name;
    v_owner := rec.owner;
    v_trigger_event := rec.triggering_event;
    
    -- Convert LONG to CLOB using DBMS_LOB
    v_trigger_body := rec.trigger_body;

    -- Build the CREATE FUNCTION SQL statement
    v_create_function_sql := 'CREATE OR REPLACE FUNCTION ' ||v_owner||'.'||v_trigger_name || '_function() RETURNS TRIGGER AS $$' || CHR(10) ||
                             'BEGIN' || CHR(10) ||
                             v_trigger_body || CHR(10) ||  -- Trigger body here
                             '  RETURN NEW;' || CHR(10) ||
                             'END;' || CHR(10) ||
                             '$$ LANGUAGE plpgsql;' || CHR(10);

    -- Build the CREATE TRIGGER SQL statement
    v_create_trigger_sql := 'CREATE OR REPLACE TRIGGER ' || v_trigger_name || CHR(10) ||
                            '  ' || CASE 
                                      WHEN v_trigger_event LIKE '%INSERT%' THEN 'AFTER INSERT'
                                      WHEN v_trigger_event LIKE '%UPDATE%' THEN 'AFTER UPDATE'
                                      WHEN v_trigger_event LIKE '%DELETE%' THEN 'AFTER DELETE'
                                      ELSE 'AFTER'  -- Default to AFTER if event type is unknown
                                   END || CHR(10) ||
                            '  ON ' || v_owner ||'.'||v_table_name || CHR(10) ||
                            '  FOR EACH ROW' || CHR(10) ||
                            '  EXECUTE FUNCTION ' || v_owner||'.'||v_trigger_name || '_function();' || CHR(10);

    -- Output the SQL statements (you can also use DBMS_OUTPUT.PUT_LINE to print the result)
    DBMS_OUTPUT.PUT_LINE(v_create_function_sql);
    DBMS_OUTPUT.PUT_LINE(v_create_trigger_sql);
  END LOOP;
END;
/
