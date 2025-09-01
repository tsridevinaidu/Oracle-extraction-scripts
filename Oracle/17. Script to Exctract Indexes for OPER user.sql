-- The query should be run at Oracle

-- Script to extract Indexes belongs to OPER role to execute on Postgresq1

SELECT 
    'CREATE ' || 
    CASE WHEN idx.UNIQUENESS = 'UNIQUE' THEN 'UNIQUE ' ELSE '' END || 
    'INDEX ' || idx.index_name || 
    ' ON ' || idx.owner || '.' || idx.table_name || 
    ' USING BTREE (' || 
    LISTAGG(col.column_name || ' ASC', ', ') WITHIN GROUP (ORDER BY col.column_position) || 
    ');' AS create_index_statement
FROM 
    all_indexes idx
JOIN 
    all_ind_columns col 
    ON idx.index_name = col.index_name 
    AND idx.table_name = col.table_name 
    AND idx.owner = col.index_owner
WHERE 
        idx.owner = 'OPER' 
    AND idx.index_name NOT LIKE '%PK%' -- Exclude index names containing 'PK'
    AND idx.index_name NOT LIKE '%UK%' -- Exclude index names containing 'UK'
    AND idx.index_name NOT LIKE '%SYS%' -- Exclude index names containing 'UK'
GROUP BY 
    idx.index_name, idx.table_name, idx.owner, idx.uniqueness
ORDER BY 
    idx.index_name;

