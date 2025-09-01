-- The query should be run at Oracle

-- Script to extract Constraints other than system generated belongs to LABORADMIN role 

SET SERVEROUTPUT ON;
DECLARE
    l_search_condition VARCHAR2(32767);  -- Large enough to hold the condition
BEGIN
    FOR rec IN (
        SELECT constraint_name, table_name, owner
        FROM all_constraints
        WHERE constraint_type = 'C'
          AND owner = 'LABORADMIN'
          AND constraint_name not like 'SYS_%'
          -- Optional: exclude system-generated constraints
    ) LOOP
        BEGIN
            -- Retrieve LONG data into VARCHAR2
            EXECUTE IMMEDIATE 'SELECT search_condition FROM all_constraints WHERE constraint_name = :1 AND owner = :2' 
            INTO l_search_condition 
            USING rec.constraint_name, rec.owner;

            DBMS_OUTPUT.PUT_LINE('ALTER TABLE ' || rec.owner || '.' || rec.table_name || 
                                 ' ADD CONSTRAINT ' || rec.constraint_name || 
                                 ' CHECK (' || l_search_condition || ');');
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error retrieving search_condition for constraint ' || rec.constraint_name);
        END;
    END LOOP;
END;
/