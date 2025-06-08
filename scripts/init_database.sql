/*
===============================================================================
Create Database and Schemas 
===============================================================================
                               
 Purpose:      Initializes the DataWarehouse database environment.
               - Drops the existing DataWarehouse database if it exists.
               - Creates a new DataWarehouse database.
               - Sets up schema layers: bronze, silver, and gold.

 Warnings:
               - This script is destructive. It will DROP the existing 
                 DataWarehouse database without confirmation.
               - All existing data in the DataWarehouse will be lost.
               - Use with caution, especially in production environments.

 Usage:        Execute using SQL Server Management Studio (SSMS) or any 
               SQL Server client with appropriate permissions.

===============================================================================
*/


-- Drop the database if it exists
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Create the database
CREATE DATABASE DataWarehouse;
GO

-- Use the newly created database
USE DataWarehouse;
GO

-- Create the necessary schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
