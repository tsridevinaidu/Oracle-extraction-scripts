-- The query should be run at Oracle

-- Script to extract Foreign Keys belongs to BILLADMIN role to execute on Postgresq1

SELECT 
    'ALTER TABLE ' || c.owner || '.' || c.table_name || 
    ' ADD CONSTRAINT ' || c.constraint_name || 
    ' FOREIGN KEY (' || LISTAGG(cc.column_name, ', ') WITHIN GROUP (ORDER BY cc.position) || 
    ') REFERENCES ' || r.owner || '.' || r.table_name || 
    ' (' || LISTAGG(rc.column_name, ', ') WITHIN GROUP (ORDER BY rc.position) || ')' || ' ON DELETE NO ACTION ;' AS ddl_statement
FROM 
    all_constraints c
JOIN 
    all_cons_columns cc ON c.constraint_name = cc.constraint_name AND c.owner = cc.owner
JOIN 
    all_constraints r ON c.r_constraint_name = r.constraint_name AND c.r_owner = r.owner
JOIN 
    all_cons_columns rc ON r.constraint_name = rc.constraint_name AND r.owner = rc.owner AND cc.position = rc.position
WHERE 
    c.constraint_type = 'R'  -- Filter for foreign keys
    AND c.owner = 'BILLADMIN'  -- Replace with your schema name
GROUP BY 
    c.owner, c.table_name, c.constraint_name, r.owner, r.table_name
ORDER BY 
    c.table_name;
