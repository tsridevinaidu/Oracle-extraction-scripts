-- The query should be run at Postgresql with Postgres user

-- Script to create Primary Keys and UNIQUE keys belongs to WMWHSEQ role.

-- Script to generate Primary Key Constraints without repeating column names
SELECT 
    'ALTER TABLE ' || owner || '.' || table_name || 
    ' ADD CONSTRAINT ' || constraint_name || ' PRIMARY KEY (' || LISTAGG(DISTINCT column_name, ', ') 
    WITHIN GROUP (ORDER BY column_position) || ');' AS ddl_statement
FROM (
    SELECT 
        c.table_name AS table_name,
        c.owner AS owner,
        cc.column_name AS column_name,
        c.constraint_name AS constraint_name,
        cc.position AS column_position
    FROM 
        all_constraints c
    JOIN 
        all_cons_columns cc ON c.constraint_name = cc.constraint_name
    WHERE 
        c.constraint_type = 'P' -- Primary key constraints
        AND c.owner = 'WMWHSE1' -- Replace 'META' with your schema name
)
GROUP BY 
    owner, table_name, constraint_name
ORDER BY 
    table_name;

SELECT 
    'ALTER TABLE ' || owner || '.' || table_name || 
    ' ADD CONSTRAINT ' || constraint_name || ' UNIQUE (' || LISTAGG(DISTINCT column_name, ', ') 
    WITHIN GROUP (ORDER BY column_position) || ');' AS ddl_statement
FROM (
    SELECT 
        c.table_name AS table_name,
        c.owner AS owner,
        cc.column_name AS column_name,
        c.constraint_name AS constraint_name,
        cc.position AS column_position
    FROM 
        all_constraints c
    JOIN 
        all_cons_columns cc ON c.constraint_name = cc.constraint_name
    WHERE 
        c.constraint_type = 'U' -- Filter for primary keys
        AND c.owner = 'WMWHSE1'      -- Replace 'OPER' with your schema name
          -- Exclude system-generated constraints
)
GROUP BY 
    owner, table_name, constraint_name  -- Group by owner, table_name, and constraint_name
ORDER BY 
    table_name;
