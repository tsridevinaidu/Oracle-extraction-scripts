-- The query should be run at Oracle

-- Script to extract tables belongs to LABORADMIN role and all datatypes will be converted to map Postgresq1

-- to view the output, DBMS output should be enabled. 

SET SERVEROUTPUT ON;
DECLARE
	l_sequence_owner   VARCHAR2(200);
    l_sequence_name    VARCHAR2(200);
    l_min_value        NUMBER;
    l_max_value        NUMBER;
    l_increment_by     NUMBER;
    l_cycle_flag       VARCHAR2(10);
    l_cache_size       NUMBER;
    l_last_number      NUMBER;
BEGIN
    FOR rec IN (SELECT SEQUENCE_OWNER, SEQUENCE_NAME, MIN_VALUE, MAX_VALUE, INCREMENT_BY, CYCLE_FLAG, CACHE_SIZE, LAST_NUMBER
                FROM DBA_SEQUENCES
                WHERE SEQUENCE_OWNER = 'LABORADMIN') 
    LOOP
        l_sequence_owner := rec.SEQUENCE_OWNER;
        l_sequence_name := rec.SEQUENCE_NAME;
        l_min_value := rec.MIN_VALUE;
        l_max_value := rec.MAX_VALUE;
        l_increment_by := rec.INCREMENT_BY;
        l_cycle_flag := rec.CYCLE_FLAG;
        l_cache_size := rec.CACHE_SIZE;
        l_last_number := rec.LAST_NUMBER;

        -- Convert Oracle sequence DDL to PostgreSQL DDL
        DBMS_OUTPUT.PUT_LINE('CREATE SEQUENCE ' || l_sequence_owner || '.' || l_sequence_name);
        DBMS_OUTPUT.PUT_LINE('  START WITH ' || l_last_number);
        DBMS_OUTPUT.PUT_LINE('  INCREMENT BY ' || l_increment_by );
        
        IF l_min_value IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('  MINVALUE ' || l_min_value );
        ELSE
            DBMS_OUTPUT.PUT_LINE('  NO MINVALUE,');
        END IF;
        
        
        IF l_max_value = '999999999999999999999999' THEN
            DBMS_OUTPUT.PUT_LINE('  MAXVALUE ' || '9223372036854775807' );
        ELSIF l_max_value IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('  MAXVALUE ' || l_max_value );
		ELSE
            DBMS_OUTPUT.PUT_LINE('  NO MAXVALUE,');
        END IF;

        IF l_cycle_flag = 'Y' THEN
            DBMS_OUTPUT.PUT_LINE('  CYCLE');
        ELSE
            DBMS_OUTPUT.PUT_LINE('  NO CYCLE');
        END IF;

        IF l_cache_size IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('  CACHE ' || l_cache_size || ';');
        ELSE
            DBMS_OUTPUT.PUT_LINE('  NO CACHE;');
        END IF;

        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
END;
/