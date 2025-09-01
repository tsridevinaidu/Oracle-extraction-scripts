-- The query should be run at Oracle

-- Script to extract tables belongs to ENTERPRISE role and all datatypes will be converted to map Postgresq1

-- to view the output, DBMS output should be enabled. 


SET SERVEROUTPUT ON;

DECLARE
    CURSOR tbl_cursor IS
        SELECT owner, table_name 
        FROM all_tables
        WHERE owner = 'ENTERPRISE';

    CURSOR col_cursor(p_table_name VARCHAR2) IS
        SELECT column_name, data_type, data_default, data_length, data_precision, data_scale, nullable
        FROM all_tab_columns
        WHERE table_name = p_table_name
        AND owner = 'ENTERPRISE'
        ORDER BY column_id;
        
    v_create_statement VARCHAR2(32767);
    v_column_definition VARCHAR2(32767);

    -- Function to manually quote literals (add single quotes around the value)
    FUNCTION quote_literal(p_value VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        RETURN '' || p_value || ''; -- Manually wrap the value in single quotes
    END;
BEGIN
    -- Loop through all tables owned by ENTERPRISE
    FOR tbl_rec IN tbl_cursor LOOP
        v_create_statement := 'CREATE TABLE ' || tbl_rec.owner || '.' || tbl_rec.table_name || ' (';
        DBMS_OUTPUT.PUT_LINE(v_create_statement);

        -- Loop through columns of the current table
        FOR col_rec IN col_cursor(tbl_rec.table_name) LOOP
            v_column_definition := CHR(9) || col_rec.column_name || ' ';

            -- Handle different data types
            IF col_rec.data_type IN ('NVARCHAR2', 'VARCHAR2', 'NVARCHAR') THEN
                v_column_definition := v_column_definition || 'VARCHAR(' || col_rec.data_length || ')';
                
                IF col_rec.data_default IS NOT NULL THEN
                    v_column_definition := v_column_definition || ' DEFAULT ' || quote_literal(col_rec.data_default);
                END IF;

            ELSIF col_rec.data_type IN ('TEXT', 'NTEXT') THEN
                v_column_definition := v_column_definition || 'TEXT';
                
                IF col_rec.data_default IS NOT NULL THEN
                    v_column_definition := v_column_definition || ' DEFAULT ' || quote_literal(col_rec.data_default);
                END IF;

            ELSIF col_rec.column_name IN ('SERIAL_KEY', 'ROW_KEY') THEN
                v_column_definition := v_column_definition || 'BIGINT';

            ELSIF col_rec.data_type = 'NUMBER' THEN
                v_column_definition := v_column_definition || 'NUMERIC';

                -- Handle precision and scale for NUMBER type
                IF col_rec.data_precision IS NOT NULL THEN
                    v_column_definition := v_column_definition || '(' || col_rec.data_precision;
                    IF col_rec.data_scale IS NOT NULL THEN
                        v_column_definition := v_column_definition || ',' || col_rec.data_scale;
                    END IF;
                    v_column_definition := v_column_definition || ')';
                END IF;

                IF col_rec.data_default IS NOT NULL THEN
                    v_column_definition := v_column_definition || ' DEFAULT ' || quote_literal(col_rec.data_default);
                END IF;

            ELSIF col_rec.data_type = 'CHAR' THEN
                v_column_definition := v_column_definition || 'CHAR(' || col_rec.data_length || ')';
                
                IF col_rec.data_default IS NOT NULL THEN
                    v_column_definition := v_column_definition || ' DEFAULT ' || quote_literal(col_rec.data_default);
                END IF;

            ELSIF col_rec.data_type = 'DATE' THEN
                IF col_rec.data_default = 'SYS_EXTRACT_UTC(SYSTIMESTAMP)' THEN
                    v_column_definition := v_column_definition || 'DATE' || ' DEFAULT NOW()' ||'';
			  ELSIF col_rec.column_name = 'ADDDATE' THEN
                 v_column_definition := v_column_definition || 'DATE' || ' DEFAULT NOW()' ||' NOT NULL' ||'';
			  ELSIF col_rec.column_name = 'EDITDATE' THEN
                 v_column_definition := v_column_definition || 'DATE' || ' DEFAULT NOW()' ||'';
              ELSIF col_rec.data_default = 'SYSDATE' THEN
                    v_column_definition := v_column_definition || 'DATE' || ' DEFAULT TIMEOFDAY()' ||'';
				ELSE
                    v_column_definition := v_column_definition || 'DATE' ;
                END IF;

            ELSIF col_rec.data_type = 'CLOB' OR col_rec.data_type = 'NCLOB' THEN
                v_column_definition := v_column_definition || 'TEXT';

            ELSIF col_rec.data_type = 'NCHAR' THEN
                v_column_definition := v_column_definition || 'VARCHAR(' || col_rec.data_length || ')';

            ELSIF col_rec.data_type = 'DATETIME' THEN
                v_column_definition := v_column_definition || 'DATETIME2';

            ELSIF col_rec.data_type = 'TIMESTAMP' THEN
                v_column_definition := v_column_definition || 'TIMESTAMP2';

            ELSIF col_rec.data_type = 'TIMESTAMP WITH TIME ZONE' THEN
                v_column_definition := v_column_definition || 'TIMESTAMPZ';

            ELSIF col_rec.data_type IN ('INTERVAL DAY TO SECOND', 'INTERVAL YEAR TO MONTH') THEN
                v_column_definition := v_column_definition || 'INTERVAL';

            ELSIF col_rec.data_type = 'NUMBER(1)' THEN
                v_column_definition := v_column_definition || 'BOOLEAN';

            ELSIF col_rec.data_type = 'NUMBER(3)' THEN
                v_column_definition := v_column_definition || 'SMALLINT';

            ELSIF col_rec.data_type = 'RAW(16)' THEN
                v_column_definition := v_column_definition || 'UUID';

            ELSIF col_rec.data_type = 'BINARY_DOUBLE' THEN
                v_column_definition := v_column_definition || 'DOUBLE PRECISION';
            
            ELSIF col_rec.data_type = 'BINARY_FLOAT' THEN
                v_column_definition := v_column_definition || 'REAL';

            ELSIF col_rec.data_type = 'XMLTYPE' THEN
                v_column_definition := v_column_definition || 'XML';

            ELSIF col_rec.data_type = 'ROWID' THEN
                v_column_definition := v_column_definition || 'CHAR(10)';

            ELSIF col_rec.data_type IN ('RAW', 'LONG RAW') THEN
                v_column_definition := v_column_definition || 'BYTEA';

            ELSIF col_rec.data_type = 'BLOB' THEN
                v_column_definition := v_column_definition || 'BYTEA';

            ELSE
                v_column_definition := v_column_definition || col_rec.data_type;
            END IF;

            -- Add NOT NULL constraint if applicable
            IF col_rec.nullable = 'N' THEN
                v_column_definition := v_column_definition || ' NOT NULL';
            END IF;

            -- Close column definition with comma if not the last column
            v_column_definition := v_column_definition || ', ';
        
            -- Output the column definition
            DBMS_OUTPUT.PUT_LINE(v_column_definition);
        END LOOP;

        -- Close the table definition with a parenthesis
        DBMS_OUTPUT.PUT_LINE(');');
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
END;
/
