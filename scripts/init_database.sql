/*

=========================================================================
Create Database and Schemas
=========================================================================

Script Purpose:
    This script creates a new database named 'DataWarehouse' after cheking if it already exists.
    If the database exists , it is dropped and recreated . Additionally , the script sets up three
    schemas within the database : 'bronze' , 'silver', and 'gold'.

WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists.
    All data in the database will be permanently deleted. Proceed with caution
    and ensure you have proper backups before before running this script.
*/

USE master;
GO


--Drop and recreate the 'DataWarehouse' database

IF EXISTS ( SELECT 1 FROM sys.databases WHERE name = 'ECommerceAnalytics')
BEGIN
    ALTER DATABASE ECommerceAnalytics SET SINGLE_USER WITH ROLLBACK IMMIDIATE;
    DROP DATABASE ECommerceAnalytics;
END;
GO 


-- Create the 'ECommerceAnalytics' database
CREATE DATABASE ECommerceAnalytics;
GO

USE ECommerceAnalytics;
GO


-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO 
