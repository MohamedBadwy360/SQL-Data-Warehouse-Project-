/*
==========================================
Create Database and Schemas
==========================================
Script Purpose:
	This script create a database called DataWarehouse after checking it's alreading exists.
	If the database exists, it's dropped and recreated.
	Additionally, the script sets up three schemas within the database (bronze, silver, gold)

WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/



USE master;
GO

-- Drop and create the database DataWarehouse
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END
GO

-- Create database DataWarehouse
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO