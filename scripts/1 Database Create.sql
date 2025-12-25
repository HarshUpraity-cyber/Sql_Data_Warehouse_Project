 Use master;
 GO

 --Drop and recreate the 'DataWarehouse' database
 IF exists (select 1 from sys.databases where name='DataWarehouse')
 Begin
	Alter DATABASE  DataWarehouse SET Single_user with Rollback Immediate;
	Drop DATABASE DataWarehouse;
End;
Go

--Create the 'DataWarehouse' database
Create Database DataWarehouse;
Go

Use DataWarehouse;
Go

--Create Schemas
Create Schema bronze;
Go

Create Schema silver;
Go

Create Schema gold;
Go