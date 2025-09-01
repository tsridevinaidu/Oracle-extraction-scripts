-- The query should be run at Oracle

-- Script to extract Views belongs to OPER role 

-- to view the output, DBMS output should be enabled. 

SET SERVEROUTPUT ON;
DECLARE
    CURSOR view_cursor IS
        SELECT owner, view_name, text
        FROM ALL_views where owner='OPER'
        order by view_name;  -- Use all_views for all user views
    view_definition VARCHAR2(32767);
BEGIN
    FOR rec IN view_cursor LOOP
       view_definition:= ('CREATE or REPLACE VIEW ' || rec.owner || '.' || rec.view_name || ' AS ' || rec.text || ';');
        DBMS_OUTPUT.PUT_LINE (view_definition);
        
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE(');'); -- Close the table definition
        DBMS_OUTPUT.PUT_LINE('');
END;
/