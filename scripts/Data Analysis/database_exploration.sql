/*
===============================================================================
Purpose:
    This script is used to explore the database schema by retrieving metadata 
    about tables and their columns using the INFORMATION_SCHEMA views.

Details:
    - Lists all tables in the database.
    - Lists all columns with details like name, nullability, data type, and 
      maximum character length.

Usage:
    Useful for understanding the structure of a database before performing
    further development, analysis.
===============================================================================
*/

-- List all tables in the current database
SELECT * FROM INFORMATION_SCHEMA.TABLES;

-- List all columns with key attributes
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    IS_NULLABLE,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS;
