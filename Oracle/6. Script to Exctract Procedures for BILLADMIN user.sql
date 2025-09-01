-- The query ran on Postgresq1 after creating all procedures using AWS SCT  with Postgres user

-- Script to extract Procedures belongs to META role 1

SET SERVEROUTPUT ON;
DECLARE
    CURSOR PROCED_cursor IS
        SELECT DISTINCT owner, object_name
        FROM all_procedures
        WHERE owner = 'BILLADMIN' 
          AND object_type = 'PROCEDURE';

    PROCED_definition CLOB := '';
    
BEGIN
    FOR rec IN PROCED_cursor LOOP
        -- Initialize the procedure definition for each procedure
        PROCED_definition := 'CREATE OR REPLACE PROCEDURE ' || rec.owner || '.'  ;
        
        -- Concatenate the procedure's source code from the ALL_SOURCE view
        FOR src IN (
            SELECT text
            FROM all_source
            WHERE owner = rec.owner
              AND name = rec.object_name
              AND type = 'PROCEDURE'
            ORDER BY line
        ) LOOP
            PROCED_definition := PROCED_definition || src.text;
        END LOOP;
        
        -- Output the complete procedure definition
        DBMS_OUTPUT.PUT_LINE(SUBSTR(PROCED_definition, 1, 32767)); -- To avoid exceeding buffer limits
        
        -- Optionally reset the PROCED_definition for the next procedure
        PROCED_definition := '';
    END LOOP;
END;
/
