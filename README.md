# PoMaDoS
## Poor man's documentation for SQL Server
This repository contains scripts that hide the complexity of the functions needed in Transact-SQL to select, insert, update and delete extended properties in SQL Server.

By default extended properties in SQL Server can only be manipulated using the functions and procedures *fn_listextendedproperty*, *sp_addextendedproperty*, *sp_updateextendedproperty* and *sp_dropextendedproperty*. 
Although these functions allow us to manipulte the extended properties of nearly all objects used in SQL Server, the usage is inconsistent with the SELECT, INSERT, UPDATE, DELETE commands we normally use.
It would be nice to show and edit userdefined properties in a tabular way.

Let's see an example: We want to add two extended properties (MS_Description and Contact) to a table:
```SQL
CREATE TABLE dbo.FirstTable(id int)
GO
EXEC sp_addextendedproperty 'MS_Description', 'My first table',  'SCHEMA', 'dbo', 'TABLE', 'FirstTable', default, default
EXEC sp_addextendedproperty 'Contact', 'me@demo.com',  'SCHEMA', 'dbo', 'TABLE', 'FirstTable', default, default

SELECT * FROM ::fn_listextendedproperty(default, 'schema', 'dbo', 'TABLE', 'FirstTable',default, default)
```
The result is:

  objtype            | objname    | name    | value
---------------------|------------|---------|-----------
TABLE                | FirstTable | Contact | me@demo.com
TABLE                | FirstTable | MS_Description | My first table

Would'nt it feel more natural to just select the extended properties of the table like 
```SQL
SELECT * FROM Documentation.ExtendedTableProperties WHERE TABLE_NAME = 'FirstTable'
```
and get a result like :

SCHEMA_NAME       | TABLE_NAME | Contact |MS_Description
-------------------|------------|--------|----------------
dbo          | FirstTable | me@demo.com | My first table

And changing/setting the value would just be an update:
```SQL
UPDATE Documentation.ExtendedTableProperties SET Contact = 'new@demo.com' WHERE Contact = 'me@demo.com'
SELECT * FROM Documentation.ExtendedTableProperties WHERE TABLE_NAME = 'FirstTable'
```
SCHEMA_NAME       | TABLE_NAME | Contact |MS_Description
-------------------|------------|--------|----------------
dbo          | FirstTable | new@demo.com | My first table




