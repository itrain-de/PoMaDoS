--drop TABLE [Documentation].[ExtendedPropertiesConfiguration]
SET NOCOUNT ON
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Documentation')
	EXEC sp_executeSQL N'CREATE SCHEMA Documentation'
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name ='ExtendedPropertiesConfiguration' AND SCHEMA_NAME(schema_id) = 'Documentation')
BEGIN
	CREATE TABLE [Documentation].[ExtendedPropertiesConfiguration](
		[objtype] [nvarchar](255) NOT NULL,
		[propertyname] [nvarchar](255) NOT NULL,
		[usagecount] [int] NULL,
		[includeinview] [bit] NULL,
		[columnnumber] [int] NULL,
		[ismsshipped] [bit] NULL
	) 
	ALTER TABLE [Documentation].[ExtendedPropertiesConfiguration]  WITH CHECK ADD  CONSTRAINT [CK_ExtendedPropertiesConfiguration] CHECK  (([objtype]='XML SCHEMA COLLECTION' OR [objtype]='VIEW' OR [objtype]='TYPE' OR [objtype]='TRIGGER' OR [objtype]='TABLE' OR [objtype]='SYNONYM' OR [objtype]='SERVICE' OR [objtype]='SCHEMA' OR [objtype]='RULE' OR [objtype]='QUEUE' OR [objtype]='PROCEDURE' OR [objtype]='PARAMETER' OR [objtype]='LOGICAL FILE NAME' OR [objtype]='INDEX' OR [objtype]='FUNCTION' OR [objtype]='FOREIGNKEY' OR [objtype]='FILEGROUP' OR [objtype]='EVENT NOTIFICATION' OR [objtype]='DEFAULT' OR [objtype]='DATABASE TRIGGER' OR [objtype]='DATABASE' OR [objtype]='CONTRACT' OR [objtype]='CONSTRAINT' OR [objtype]='COLUMN' OR [objtype]='ASSEMBLY' OR [objtype]='AGGREGATE'))
	ALTER TABLE [Documentation].[ExtendedPropertiesConfiguration] CHECK CONSTRAINT [CK_ExtendedPropertiesConfiguration]
END 
GO
IF NOT EXISTS (SELECT * FROM Documentation.ExtendedPropertiesConfiguration)
BEGIN
	INSERT INTO Documentation.ExtendedPropertiesConfiguration VALUES ('DATABASE', 'MS_Description',  0, 1, 1, 1)
	INSERT INTO Documentation.ExtendedPropertiesConfiguration VALUES ('ASSEMBLY', 'MS_Description',  0, 1, 1, 1)
	INSERT INTO Documentation.ExtendedPropertiesConfiguration VALUES ('CONTRACT', 'MS_Description',  0, 1, 1, 1)
	INSERT INTO Documentation.ExtendedPropertiesConfiguration VALUES ('FILEGROUP', 'MS_Description',  0, 1, 1, 1)
	INSERT INTO Documentation.ExtendedPropertiesConfiguration VALUES ('SCHEMA', 'MS_Description',  0, 1, 1, 1)
	INSERT INTO Documentation.ExtendedPropertiesConfiguration VALUES ('SERVICE', 'MS_Description',  0, 1, 1, 1)
	INSERT INTO Documentation.ExtendedPropertiesConfiguration VALUES ('DATABASE TRIGGER', 'MS_Description',  0, 1, 1, 1)
	INSERT INTO Documentation.ExtendedPropertiesConfiguration VALUES ('AGGREGATE', 'MS_Description',  0, 1, 1, 1)
	INSERT INTO Documentation.ExtendedPropertiesConfiguration VALUES ('DEFAULT', 'MS_Description',  0, 1, 1, 1)
	INSERT INTO Documentation.ExtendedPropertiesConfiguration VALUES ('FUNCTION', 'MS_Description',  0, 1, 1, 1)
	INSERT INTO Documentation.ExtendedPropertiesConfiguration VALUES ('LOGICAL FILE NAME', 'MS_Description',  0, 1, 1, 1)
	INSERT INTO Documentation.ExtendedPropertiesConfiguration VALUES ('PROCEDURE', 'MS_Description',  0, 1, 1, 1)
	INSERT INTO Documentation.ExtendedPropertiesConfiguration VALUES ('QUEUE', 'MS_Description',  0, 1, 1, 1)
	INSERT INTO Documentation.ExtendedPropertiesConfiguration VALUES ('RULE', 'MS_Description',  0, 1, 1, 1)
	INSERT INTO Documentation.ExtendedPropertiesConfiguration VALUES ('SYNONYM', 'MS_Description',  0, 1, 1, 1)
	INSERT INTO Documentation.ExtendedPropertiesConfiguration VALUES ('TABLE', 'MS_Description',  0, 1, 1, 1)
	INSERT INTO Documentation.ExtendedPropertiesConfiguration VALUES ('VIEW', 'MS_Description',  0, 1, 1, 1)
	INSERT INTO Documentation.ExtendedPropertiesConfiguration VALUES ('TYPE', 'MS_Description',  0, 1, 1, 1)
	INSERT INTO Documentation.ExtendedPropertiesConfiguration VALUES ('XML SCHEMA COLLECTION', 'MS_Description',  0, 1, 1, 1)
	INSERT INTO Documentation.ExtendedPropertiesConfiguration VALUES ('COLUMN', 'MS_Description',  0, 1, 1, 1)
	INSERT INTO Documentation.ExtendedPropertiesConfiguration VALUES ('CONSTRAINT', 'MS_Description',  0, 1, 1, 1)
	INSERT INTO Documentation.ExtendedPropertiesConfiguration VALUES ('EVENT NOTIFICATION', 'MS_Description',  0, 1, 1, 1)
	INSERT INTO Documentation.ExtendedPropertiesConfiguration VALUES ('INDEX', 'MS_Description',  0, 1, 1, 1)
	INSERT INTO Documentation.ExtendedPropertiesConfiguration VALUES ('PARAMETER', 'MS_Description',  0, 1, 1, 1)
	INSERT INTO Documentation.ExtendedPropertiesConfiguration VALUES ('TRIGGER', 'MS_Description',  0, 1, 1, 1)
END
GO
CREATE OR ALTER  PROC	Documentation.syncExtendedPropertiesConfigurationCount
AS
SET NOCOUNT ON
MERGE INTO [Documentation].[ExtendedPropertiesConfiguration] trg
USING (SELECT	DISTINCT	xpr.name, 
							CASE WHEN so.type IN ('U') THEN 'TABLE'
								 WHEN so.type IN ('V') THEN 'VIEW'
								 WHEN so.type IN ('FN', 'TF', 'TF') THEN 'FUNCTION'
								 WHEN so.type IN ('P') THEN 'PROCEDURE' 
								 WHEN so.type IN ('F') THEN 'FOREIGNKEY'
								 WHEN so.type IN ('TR') THEN 'TRIGGER'
								 ELSE so.Type END objtype,
							COUNT(*)  num
		FROM		sys.extended_properties xpr
		INNER JOIN  sys.objects so
		ON			so.object_id = major_id 
		AND			class_desc = 'OBJECT_OR_COLUMN'
		AND			minor_id = 0
		GROUP BY	xpr.name, CASE	WHEN so.type IN ('U') THEN 'TABLE'
									WHEN so.type IN ('V') THEN 'VIEW'
									WHEN so.type IN ('FN', 'TF', 'TF') THEN 'FUNCTION'
									WHEN so.type IN ('P') THEN 'PROCEDURE' 
									WHEN so.type IN ('F') THEN 'FOREIGNKEY'
									WHEN so.type IN ('TR') THEN 'TRIGGER'
									ELSE so.Type END ) src
ON (	src.name = trg.propertyname  AND src.objtype = trg.objtype COLLATE Latin1_General_CI_AS)
 WHEN MATCHED THEN 
	UPDATE SET usagecount = num
WHEN NOT MATCHED BY target THEN 
	INSERT (objtype, propertyname, usagecount, includeinview) VALUES ( src.objtype, src.name, src.num, 1)
WHEN NOT MATCHED BY source AND trg.objtype IN ('TABLE', 'VIEW', 'FUNCTION', 'PROCEDURE', 'FOREIGNKEY', 'TRIGGER') THEN 
	UPDATE SET usagecount = 0 
;

MERGE INTO [Documentation].[ExtendedPropertiesConfiguration] trg
USING (	SELECT		DISTINCT	xpr.name, 
								'COLUMN' objtype,  
								COUNT(*) num
		FROM		sys.extended_properties xpr
		INNER JOIN  sys.objects so
		ON			so.object_id = major_id 
		INNER JOIN	sys.columns col
		ON			col.column_id = xpr.minor_id
		AND			class_desc = 'OBJECT_OR_COLUMN'
		AND			so.object_id = col.object_id 
		GROUP BY	xpr.name) src
ON (	src.name = trg.propertyname AND src.objtype = trg.objtype COLLATE Latin1_General_CI_AS)
 WHEN MATCHED THEN 
	UPDATE SET usagecount = num
WHEN NOT MATCHED BY target THEN 
	INSERT (objtype, propertyname, usagecount, includeinview) VALUES ( src.objtype, src.name, src.num, 1)
WHEN NOT MATCHED BY source AND trg.objtype IN ('COLUMN') THEN 
	UPDATE SET usagecount = 0 
;

MERGE INTO [Documentation].[ExtendedPropertiesConfiguration] trg
USING (	SELECT	DISTINCT	xpr.name, 
							'PARAMETER' objtype, 
							COUNT(*) num
		FROM		sys.extended_properties xpr
		INNER JOIN	sys.foreign_keys fk
		ON			fk.object_id = xpr.major_id
		AND			class_desc = 'OBJECT_OR_COLUMN'
		INNER JOIN  sys.objects so
		ON			so.object_id = fk.parent_object_id 
		GROUP BY	xpr.name) src
ON (	src.name = trg.propertyname AND src.objtype = trg.objtype COLLATE Latin1_General_CI_AS)
 WHEN MATCHED THEN 
	UPDATE SET usagecount = num
WHEN NOT MATCHED BY target THEN 
	INSERT (objtype, propertyname, usagecount, includeinview) VALUES ( src.objtype, src.name, src.num, 1)
WHEN NOT MATCHED BY source AND trg.objtype IN ('PARAMETER') THEN 
	UPDATE SET usagecount = 0 
;
GO

EXEC Documentation.syncExtendedPropertiesConfigurationCount
GO

CREATE OR ALTER   PROC	[Documentation].[GenerateExtendedTablePropertiesView]
				@Debug bit = 0 
AS
SET NOCOUNT ON
DECLARE @SQLView nvarchar(max)
DECLARE @SQLTrigger nvarchar(max)
DECLARE @SQLColumn nvarchar(max) = '', @SQLApply nvarchar(max) = ''
DECLARE @columnlist nvarchar(max)
DECLARE @ViewName nvarchar(255), @PropertyName nvarchar(255)
SET @ViewName = 'ExtendedTableProperties'
DECLARE cProperties CURSOR LOCAL FAST_FORWARD FOR 
	SELECT	propertyname 
	FROM	Documentation.ExtendedPropertiesConfiguration 
	WHERE	objtype = 'TABLE' 
	AND		includeinview = 1
	ORDER BY columnnumber
OPEN cProperties
FETCH NEXT FROM cProperties INTO @propertyName --, @DisplayName
WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @SQLColumn += ', CAST(' + QUOTENAME(@propertyName) + '.value AS nvarchar(4000))  ' + QUOTENAME(@PropertyName)
	SET @SQLApply += 'OUTER APPLY ::fn_listextendedproperty(''' + @PropertyName +  ''', ''schema'', SCHEMA_NAME(schema_id), ''TABLE'', tab.name, DEFAULT, DEFAULT)	' + QUOTENAME(@PropertyName) 
	SET @columnlist = ISNULL(@columnlist + ', ' + QUOTENAME(@PropertyName) , QUOTENAME(@PropertyName))
	FETCH NEXT FROM cProperties INTO @propertyName --, @DisplayName
END 
CLOSE cProperties
DEALLOCATE cProperties

SET @SQLView = 'CREATE OR ALTER VIEW [Documentation].' + QUOTENAME(@ViewName) + '
WITH VIEW_METADATA
AS
SELECT		CAST(SCHEMA_NAME(Schema_id) AS nvarchar(255))				[SCHEMA_NAME] , 
			CAST(tab.name AS nvarchar(255))							    [TABLE_NAME] '
SET @SQLView += @SQLColumn
SET @SQLView += '
FROM sys.tables tab
'
SET @SQLView += @SQLApply
IF @Debug = 1 PRINT @SQLView
EXEC sp_executeSQL @SQLView 

SET @SQLTrigger = 'CREATE OR ALTER TRIGGER [Documentation].' + QUOTENAME( @ViewName + 'Trigger') + ' ON [Documentation].' + QUOTENAME(@ViewName) + '
INSTEAD OF UPDATE
AS
SET NOCOUNT ON
	DECLARE @colBitmap varbinary(2)
	DECLARE @NumOfColumns int
	DECLARE @Schema varchar(255)
	DECLARE @Property varchar(255)
	DECLARE @Table sysname
	DECLARE @Value SQL_VARIANT
	DECLARE @Changes TABLE (schemaName sysname, tabName sysName, Value SQL_VARIANT, PropName varchar(255))
	DECLARE @curColumnId int = 1
	INSERT INTO @Changes
		SELECT	*
		FROM	(SELECT	*	FROM	inserted i
				 UNPIVOT	(Res FOR Value IN ( ' + @columnlist + ') ) un ) un

	DECLARE cDaten CURSOR FAST_FORWARD FOR 
		SELECT		SCHEMA_NAME, 
					TABLE_NAME
		FROM		inserted i
	OPEN cDaten
	FETCH NEXT FROM cDaten INTO @Schema, @Table
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @curColumnId = 3	-- ignore first 2columns
		SELECT @NumOfColumns = COUNT(*) FROM sys.columns WHERE OBJECT_ID(''Documentation.' + @ViewName + ''') = object_id
		IF @NumOfColumns < 9	
				SET @colBitmap = SUBSTRING( COLUMNS_UPDATED(), 1, 1)
		ELSE
				SET @colBitmap = SUBSTRING( COLUMNS_UPDATED(), 2, 1) + SUBSTRING(Columns_UPDATED(), 1,1)
			WHILE @curColumnId <= @NumOfColumns
			BEGIN
				IF @colBitmap & POWER(2, (@curColumnId -1)) = POWER(2, (@curColumnId -1)) 
				BEGIN
					SET		@Value = NULL
					SELECT	@Property = name 
					FROM	sys.columns 
					WHERE	OBJECT_ID(''Documentation.' + @ViewName + ''') = object_id 
					AND		column_id = @curColumnId
					SELECT	@Value = Value 
					FROM	@Changes 
					WHERE	PropName = @Property 
					AND		SchemaName = @Schema
					AND		TabName = @Table
					IF EXISTS (SELECT * FROM ::fn_listextendedproperty(@Property, ''schema'', @schema, ''table'', @Table, DEFAULT, DEFAULT))
					BEGIN
						IF @Value IS NULL OR DATALENGTH(@Value) = 0 
						BEGIN
							EXEC sp_dropextendedproperty  @Property, ''schema'', @schema, ''table'', @Table, DEFAULT, DEFAULT
						END
						ELSE
						BEGIN
							EXEC sp_updateextendedproperty @Property,  @Value,  ''schema'', @schema, ''table'', @Table, DEFAULT, DEFAULT
						END
					END
					ELSE
					BEGIN
						IF @Value IS NOT NULL AND DATALENGTH(@Value) > 0 
							EXEC sp_addextendedproperty @Property, @Value,  ''schema'', @Schema, ''table'', @Table, DEFAULT, DEFAULT
					END
				END -- Change detected
				SET @curColumnId += 1
			END
	FETCH NEXT FROM cDaten INTO @Schema, @Table
	END
	CLOSE cDaten
	DEALLOCATE cDaten
'
EXEC sp_executeSQL @SQLTrigger
IF @Debug = 1 PRINT @SQLTrigger
GO

CREATE  OR ALTER  PROC	[Documentation].[GenerateExtendedViewPropertiesView]
						@Debug bit = 0 
AS
SET NOCOUNT ON
DECLARE @SQLView nvarchar(max)
DECLARE @SQLTrigger nvarchar(max)
DECLARE @SQLColumn nvarchar(max) = '', @SQLApply nvarchar(max) = ''
DECLARE @columnlist nvarchar(max)
DECLARE @ViewName nvarchar(255), @PropertyName nvarchar(255), @DisplayName nvarchar(255)
SET @ViewName = 'ExtendedViewProperties'
DECLARE cProperties CURSOR LOCAL FAST_FORWARD FOR 
	SELECT  propertyname 
	FROM	Documentation.ExtendedPropertiesConfiguration 
	WHERE	objtype = 'VIEW' 
	AND		includeinview = 1
	ORDER BY columnnumber
OPEN cProperties
FETCH NEXT FROM cProperties INTO @propertyName 
WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @SQLColumn += ', CAST(' + QUOTENAME(@propertyName) + '.value AS nvarchar(4000))  ' + QUOTENAME(@PropertyName)
	SET @SQLApply += 'OUTER APPLY ::fn_listextendedproperty(''' + @PropertyName +  ''', ''schema'', SCHEMA_NAME(schema_id), ''VIEW'', viw.name, DEFAULT, DEFAULT)	' + QUOTENAME(@PropertyName) 
	SET @columnlist = ISNULL(@columnlist + ', ' + QUOTENAME(@PropertyName) , QUOTENAME(@PropertyName))
	FETCH NEXT FROM cProperties INTO @propertyName
END 
CLOSE cProperties
DEALLOCATE cProperties

SET @SQLView = 'CREATE OR ALTER VIEW [Documentation].' + QUOTENAME(@ViewName) + '
WITH VIEW_METADATA
AS
SELECT		CAST(SCHEMA_NAME(Schema_id) AS nvarchar(255))				[SCHEMA_NAME] , 
			CAST(viw.name AS nvarchar(255))							    [VIEW_NAME] '
SET @SQLView += @SQLColumn
SET @SQLView += '
FROM sys.views viw
'
SET @SQLView += @SQLApply
IF @Debug = 1 PRINT @SQLView
EXEC sp_executeSQL @SQLView 

SET @SQLTrigger = 'CREATE OR ALTER TRIGGER [Documentation].' + QUOTENAME( @ViewName + 'Trigger') + ' ON [Documentation].' + QUOTENAME(@ViewName) + '
INSTEAD OF UPDATE
AS
SET NOCOUNT ON
	DECLARE @colBitmap varbinary(2)
	DECLARE @NumOfColumns int
	DECLARE @Schema varchar(255)
	DECLARE @Property varchar(255)
	DECLARE @View sysname
	DECLARE @Value SQL_VARIANT
	DECLARE @Changes TABLE (schemaName sysname, tabName sysName, Value SQL_VARIANT, PropName varchar(255))
	DECLARE @curColumnId int = 1
	INSERT INTO @Changes
		SELECT	*
		FROM	(SELECT	*	FROM	inserted i
				 UNPIVOT	(Res FOR Value IN ( ' + @columnlist + ') ) un ) un

	DECLARE cDaten CURSOR FAST_FORWARD FOR 
		SELECT		SCHEMA_NAME, 
					VIEW_NAME
		FROM		inserted i
	OPEN cDaten
	FETCH NEXT FROM cDaten INTO @Schema, @View
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @curColumnId = 3	-- ignore first 2columns
		SELECT @NumOfColumns = COUNT(*) FROM sys.columns WHERE OBJECT_ID(''Documentation.' + @ViewName + ''') = object_id
		IF @NumOfColumns < 9	
				SET @colBitmap = SUBSTRING( COLUMNS_UPDATED(), 1, 1)
		ELSE
				SET @colBitmap = SUBSTRING( COLUMNS_UPDATED(), 2, 1) + SUBSTRING(Columns_UPDATED(), 1,1)
			WHILE @curColumnId <= @NumOfColumns
			BEGIN
				IF @colBitmap & POWER(2, (@curColumnId -1)) = POWER(2, (@curColumnId -1)) 
				BEGIN
					SET		@Value = NULL
					SELECT	@Property = name 
					FROM	sys.columns 
					WHERE	OBJECT_ID(''Documentation.' + @ViewName + ''') = object_id 
					AND		column_id = @curColumnId
					SELECT	@Value = Value 
					FROM	@Changes 
					WHERE	PropName = @Property 
					AND		SchemaName = @Schema
					AND		TabName = @View
					IF EXISTS (SELECT * FROM ::fn_listextendedproperty(@Property, ''schema'', @schema, ''view'', @View, DEFAULT, DEFAULT))
					BEGIN
						IF @Value IS NULL OR DATALENGTH(@Value) = 0 
						BEGIN
							EXEC sp_dropextendedproperty  @Property, ''schema'', @schema, ''view'', @View, DEFAULT, DEFAULT
						END
						ELSE
						BEGIN
							EXEC sp_updateextendedproperty @Property,  @Value,  ''schema'', @schema, ''view'', @View, DEFAULT, DEFAULT
						END
					END
					ELSE
					BEGIN
						IF @Value IS NOT NULL AND DATALENGTH(@Value) > 0 
							EXEC sp_addextendedproperty @Property, @Value,  ''schema'', @Schema, ''view'', @View, DEFAULT, DEFAULT
					END
				END -- Change detected
				SET @curColumnId =@curColumnId + 1
			END
	FETCH NEXT FROM cDaten INTO @Schema, @View
	END
	CLOSE cDaten
	DEALLOCATE cDaten
'
EXEC sp_executeSQL @SQLTrigger
IF @Debug = 1 PRINT @SQLTrigger
GO

CREATE OR ALTER  PROC	[Documentation].[GenerateExtendedTriggerPropertiesView]
						@Debug bit = 0 
AS
SET NOCOUNT ON
DECLARE @SQLView nvarchar(max)	
DECLARE @SQLTrigger nvarchar(max)
DECLARE @SQLColumn nvarchar(max) = '', @SQLApply nvarchar(max) = ''
DECLARE @columnlist nvarchar(max)
DECLARE @ViewName nvarchar(255), @PropertyName nvarchar(255), @DisplayName nvarchar(255)
SET @ViewName = 'ExtendedTriggerProperties'
DECLARE cProperties CURSOR LOCAL FAST_FORWARD FOR 
	SELECT	propertyname	
	FROM	Documentation.ExtendedPropertiesConfiguration 
	WHERE	objtype = 'TRIGGER' 
	AND		includeinview = 1
	ORDER BY columnnumber
OPEN cProperties
FETCH NEXT FROM cProperties INTO @propertyName	
WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @SQLColumn += ', CAST(' + QUOTENAME(@propertyName) + '.value AS nvarchar(4000))  ' + QUOTENAME(@PropertyName)
	SET @SQLApply += 'OUTER APPLY ::fn_listextendedproperty(''' + @PropertyName +  ''', ''schema'', SCHEMA_NAME(schema_id), CASE WHEN so.type = ''U'' THEN ''TABLE'' WHEN so.type = ''V'' THEN ''VIEW'' WHEN so.type IN (''TF'',''IF'') THEN ''FUNCTION'' ELSE ''UNKNOWN'' END  ,  so.name, ''TRIGGER'', col.name)	' + QUOTENAME(@PropertyName) 
	SET @columnlist = ISNULL(@columnlist + ', ' + QUOTENAME(@PropertyName) , QUOTENAME(@PropertyName))
	FETCH NEXT FROM cProperties INTO @propertyName	
END 
CLOSE cProperties
DEALLOCATE cProperties

SET @SQLView = 'CREATE OR ALTER VIEW [Documentation].' + QUOTENAME(@ViewName) + '
WITH VIEW_METADATA
AS
SELECT		CASE WHEN so.type IN (''U'') THEN ''TABLE'' WHEN so.type IN (''V'') THEN ''VIEW'' WHEN so.type IN (''IF'', ''TF'') THEN ''FUNCTION'' ELSE NULL END OBJECT_TYPE,
			CAST(SCHEMA_NAME(Schema_id) AS nvarchar(255))				[SCHEMA_NAME] , 
			CAST(so.name AS nvarchar(255))							    [OBJECT_NAME] , 
			CAST(col.name AS nvarchar(255))                             [TRIGGER_NAME]'


SET @SQLView += @SQLColumn
SET @SQLView += '
FROM		sys.objects so
INNER JOIN	sys.triggers col
ON			col.parent_id = so.object_id
'
SET @SQLView += @SQLApply
SET @SQLView += ' WHERE so.type IN (''U'', ''V'') '
IF @Debug = 1 PRINT @SQLView
EXEC sp_executeSQL @SQLView 

SET @SQLTrigger = 'CREATE OR ALTER TRIGGER [Documentation].' + QUOTENAME( @ViewName + 'Trigger') + ' ON [Documentation].' + QUOTENAME(@ViewName) + '
INSTEAD OF UPDATE
AS
SET NOCOUNT ON
	DECLARE @colBitmap varbinary(2)
	DECLARE @NumOfColumns int
	DECLARE @Schema varchar(255)
	DECLARE @Property varchar(255)
	DECLARE @View sysname
	DECLARE @Trigger sysname
	DECLARE @Value SQL_VARIANT
	DECLARE @ObjectType varchar(255)
	DECLARE @Changes TABLE (objectType sysname, schemaName sysname, tabName sysName,colname sysname,  Value SQL_VARIANT, PropName varchar(255))
	DECLARE @curColumnId int = 1
	INSERT INTO @Changes
		SELECT	*
		FROM	(SELECT	*	FROM	inserted i
				 UNPIVOT	(Res FOR Value IN ( ' + @columnlist + ') ) un ) un

	DECLARE cDaten CURSOR FAST_FORWARD FOR 
		SELECT		SCHEMA_NAME, 
					OBJECT_NAME, 
					TRIGGER_NAME,
					OBJECT_TYPE
		FROM		inserted i
		INNER JOIN  sys.objects SO
		ON			SO.name = OBJECT_NAME AND SCHEMA_NAME(so.SCHEMA_ID) = i.SCHEMA_NAME
	OPEN cDaten
	FETCH NEXT FROM cDaten INTO @Schema, @View, @Trigger, @ObjectType
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @curColumnId = 4	-- ignore first 3 columns
		SELECT @NumOfColumns = COUNT(*) FROM sys.columns WHERE OBJECT_ID(''Documentation.' + @ViewName + ''') = object_id
		IF @NumOfColumns < 9	
				SET @colBitmap = SUBSTRING( COLUMNS_UPDATED(), 1, 1)
		ELSE
				SET @colBitmap = SUBSTRING( COLUMNS_UPDATED(), 2, 1) + SUBSTRING(Columns_UPDATED(), 1,1)
			WHILE @curColumnId <= @NumOfColumns
			BEGIN
				IF @colBitmap & POWER(2, (@curColumnId -1)) = POWER(2, (@curColumnId -1)) 
				BEGIN
					SET		@Value = NULL
					SELECT	@Property = name 
					FROM	sys.columns 
					WHERE	OBJECT_ID(''Documentation.' + @ViewName + ''') = object_id 
					AND		column_id = @curColumnId
					SELECT	@Value = Value 
					FROM	@Changes 
					WHERE	PropName = @Property 
					AND		SchemaName = @Schema
					AND		TabName = @View
					AND		ColName = @Trigger
					IF EXISTS (SELECT * FROM ::fn_listextendedproperty(@Property, ''schema'', @schema, @ObjectType, @View, ''trigger'', @Trigger))
					BEGIN
						IF @Value IS NULL OR DATALENGTH(@Value) = 0 
						BEGIN
							EXEC sp_dropextendedproperty  @Property, ''schema'', @schema, @ObjectType, @View, ''trigger'', @Trigger
						END
						ELSE
						BEGIN
							EXEC sp_updateextendedproperty @Property,  @Value,  ''schema'', @schema, @ObjectType, @View, ''trigger'', @Trigger
						END
					END
					ELSE
					BEGIN
						IF @Value IS NOT NULL AND DATALENGTH(@Value) > 0 
							EXEC sp_addextendedproperty @Property, @Value,  ''SCHEMA'', @Schema, @ObjectType, @View, ''trigger'', @Trigger
					END
				END -- Change detected
				SET @curColumnId =@curColumnId + 1
			END
	FETCH NEXT FROM cDaten INTO @Schema, @View, @Trigger, @ObjectType
	END
	CLOSE cDaten
	DEALLOCATE cDaten
'
EXEC sp_executeSQL @SQLTrigger
IF @Debug = 1 PRINT @SQLTrigger
GO



CREATE  OR ALTER   PROC	[Documentation].[GenerateExtendedProcedurePropertiesView]
					@Debug bit = 0 
AS
SET NOCOUNT ON
DECLARE @SQLView nvarchar(max)
DECLARE @SQLTrigger nvarchar(max)
DECLARE @SQLColumn nvarchar(max) = '', @SQLApply nvarchar(max) = ''
DECLARE @columnlist nvarchar(max)
DECLARE @ViewName nvarchar(255), @PropertyName nvarchar(255), @DisplayName nvarchar(255)
SET @ViewName = 'ExtendedProcedureProperties'
DECLARE cProperties CURSOR LOCAL FAST_FORWARD FOR 
	SELECT  propertyname --, displayname 
	FROM	Documentation.ExtendedPropertiesConfiguration 
	WHERE	objtype IN ('PROCEDURE') 
	AND		includeinview = 1
	ORDER BY columnnumber
OPEN cProperties
FETCH NEXT FROM cProperties INTO @propertyName --, @DisplayName
WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @SQLColumn += ', CAST(' + QUOTENAME(@propertyName) + '.value AS nvarchar(4000))  ' + QUOTENAME(@PropertyName)
	SET @SQLApply += 'OUTER APPLY ::fn_listextendedproperty(''' + @PropertyName +  ''', ''schema'', SCHEMA_NAME(schema_id), ''PROCEDURE'', fun.name, DEFAULT, DEFAULT)	' + QUOTENAME(@PropertyName) 
	SET @columnlist = ISNULL(@columnlist + ', ' + QUOTENAME(@PropertyName) , QUOTENAME(@PropertyName))
	FETCH NEXT FROM cProperties INTO @propertyName --, @DisplayName
END 
CLOSE cProperties
DEALLOCATE cProperties

SET @SQLView = 'CREATE OR ALTER VIEW [Documentation].' + QUOTENAME(@ViewName) + '
WITH VIEW_METADATA
AS
SELECT		CAST(SCHEMA_NAME(Schema_id) AS nvarchar(255))				[SCHEMA_NAME] , 
			CAST(fun.name AS nvarchar(255))							    [OBJECT_NAME] '
SET @SQLView += @SQLColumn
SET @SQLView += '
FROM sys.procedures fun
'
SET @SQLView += @SQLApply
IF @Debug = 1 PRINT @SQLView
EXEC sp_executeSQL @SQLView 

SET @SQLTrigger = 'CREATE OR ALTER TRIGGER [Documentation].' + QUOTENAME( @ViewName + 'Trigger') + ' ON [Documentation].' + QUOTENAME(@ViewName) + '
INSTEAD OF UPDATE
AS
SET NOCOUNT ON
	DECLARE @colBitmap varbinary(2)
	DECLARE @NumOfColumns int
	DECLARE @Schema varchar(255)
	DECLARE @Property varchar(255)
	DECLARE @Table sysname
	DECLARE @Value SQL_VARIANT
	DECLARE @Changes TABLE (schemaName sysname, tabName sysName, Value SQL_VARIANT, PropName varchar(255))
	DECLARE @curColumnId int = 1
	INSERT INTO @Changes
		SELECT	*
		FROM	(SELECT	*	FROM	inserted i
				 UNPIVOT	(Res FOR Value IN ( ' + @columnlist + ') ) un ) un

	DECLARE cDaten CURSOR FAST_FORWARD FOR 
		SELECT		SCHEMA_NAME, 
					OBJECT_NAME
		FROM		inserted i
	OPEN cDaten
	FETCH NEXT FROM cDaten INTO @Schema, @Table
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @curColumnId = 3	-- ignore first 2columns
		SELECT @NumOfColumns = COUNT(*) FROM sys.columns WHERE OBJECT_ID(''Documentation.' + @ViewName + ''') = object_id
		IF @NumOfColumns < 9	
				SET @colBitmap = SUBSTRING( COLUMNS_UPDATED(), 1, 1)
		ELSE
				SET @colBitmap = SUBSTRING( COLUMNS_UPDATED(), 2, 1) + SUBSTRING(Columns_UPDATED(), 1,1)
			WHILE @curColumnId <= @NumOfColumns
			BEGIN
				IF @colBitmap & POWER(2, (@curColumnId -1)) = POWER(2, (@curColumnId -1)) 
				BEGIN
					SET		@Value = NULL
					SELECT	@Property = name 
					FROM	sys.columns 
					WHERE	OBJECT_ID(''Documentation.' + @ViewName + ''') = object_id 
					AND		column_id = @curColumnId
					SELECT	@Value = Value 
					FROM	@Changes 
					WHERE	PropName = @Property 
					AND		SchemaName = @Schema
					AND		TabName = @Table
					IF EXISTS (SELECT * FROM ::fn_listextendedproperty(@Property, ''schema'', @schema, ''PROCEDURE'', @Table, DEFAULT, DEFAULT))
					BEGIN
						IF @Value IS NULL OR DATALENGTH(@Value) = 0 
						BEGIN
							EXEC sp_dropextendedproperty  @Property, ''schema'', @schema, ''PROCEDURE'', @Table, DEFAULT, DEFAULT
						END
						ELSE
						BEGIN
							EXEC sp_updateextendedproperty @Property,  @Value,  ''schema'', @schema, ''PROCEDURE'', @Table, DEFAULT, DEFAULT
						END
					END
					ELSE
					BEGIN
						IF @Value IS NOT NULL AND DATALENGTH(@Value) > 0 
							EXEC sp_addextendedproperty @Property, @Value,  ''schema'', @Schema, ''PROCEDURE'', @Table, DEFAULT, DEFAULT
					END
				END -- Change detected
				SET @curColumnId =@curColumnId + 1
			END
	FETCH NEXT FROM cDaten INTO @Schema, @Table
	END
	CLOSE cDaten
	DEALLOCATE cDaten
'
EXEC sp_executeSQL @SQLTrigger
IF @Debug = 1 PRINT @SQLTrigger
GO




CREATE   OR ALTER   PROC	[Documentation].[GenerateExtendedFunctionPropertiesView]
						@Debug bit = 0
AS
SET NOCOUNT ON
DECLARE @SQLView nvarchar(max)
DECLARE @SQLTrigger nvarchar(max)
DECLARE @SQLColumn nvarchar(max) = '', @SQLApply nvarchar(max) = ''
DECLARE @columnlist nvarchar(max)
DECLARE @ViewName nvarchar(255), @PropertyName nvarchar(255), @DisplayName nvarchar(255)
SET @ViewName = 'ExtendedFunctionProperties'
DECLARE cProperties CURSOR LOCAL FAST_FORWARD FOR 
	SELECT  propertyname --, displayname 
	FROM	Documentation.ExtendedPropertiesConfiguration 
	WHERE	objtype IN ('FUNCTION') 
	AND		includeinview = 1
	ORDER BY columnnumber
OPEN cProperties
FETCH NEXT FROM cProperties INTO @propertyName --, @DisplayName
WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @SQLColumn += ', CAST(' + QUOTENAME(@propertyName) + '.value AS nvarchar(4000))  ' + QUOTENAME(@PropertyName)
	SET @SQLApply += 'OUTER APPLY ::fn_listextendedproperty(''' + @PropertyName +  ''', ''schema'', SCHEMA_NAME(schema_id), ''FUNCTION'', fun.name, DEFAULT, DEFAULT)	' + QUOTENAME(@PropertyName) 
	SET @columnlist = ISNULL(@columnlist + ', ' + QUOTENAME(@PropertyName) , QUOTENAME(@PropertyName))
	FETCH NEXT FROM cProperties INTO @propertyName --, @DisplayName
END 
CLOSE cProperties
DEALLOCATE cProperties

SET @SQLView = 'CREATE OR ALTER VIEW [Documentation].' + QUOTENAME(@ViewName) + '
WITH VIEW_METADATA
AS
SELECT		CAST(SCHEMA_NAME(Schema_id) AS nvarchar(255))				[SCHEMA_NAME] , 
			CAST(fun.name AS nvarchar(255))							    [OBJECT_NAME] '

SET @SQLView += @SQLColumn
SET @SQLView += '
FROM sys.objects fun
'
SET @SQLView += @SQLApply
SET @SQLView += '  WHERE type IN (''FN'', ''IF'', ''TF'')'
IF @Debug = 1 PRINT @SQLView
EXEC sp_executeSQL @SQLView 

SET @SQLTrigger = 'CREATE OR ALTER TRIGGER [Documentation].' + QUOTENAME( @ViewName + 'Trigger') + ' ON [Documentation].' + QUOTENAME(@ViewName) + '
INSTEAD OF UPDATE
AS
SET NOCOUNT ON
	DECLARE @colBitmap varbinary(2)
	DECLARE @NumOfColumns int
	DECLARE @Schema varchar(255)
	DECLARE @Property varchar(255)
	DECLARE @Table sysname
	DECLARE @Value SQL_VARIANT
	DECLARE @Changes TABLE (schemaName sysname, tabName sysName, Value SQL_VARIANT, PropName varchar(255))
	DECLARE @curColumnId int = 1
	INSERT INTO @Changes
		SELECT	*
		FROM	(SELECT	*	FROM	inserted i
				 UNPIVOT	(Res FOR Value IN ( ' + @columnlist + ') ) un ) un

	DECLARE cDaten CURSOR FAST_FORWARD FOR 
		SELECT		SCHEMA_NAME, 
					OBJECT_NAME
		FROM		inserted i
	OPEN cDaten
	FETCH NEXT FROM cDaten INTO @Schema, @Table
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @curColumnId = 3	-- ignore first 2columns
		SELECT @NumOfColumns = COUNT(*) FROM sys.columns WHERE OBJECT_ID(''Documentation.' + @ViewName + ''') = object_id
		IF @NumOfColumns < 9	
				SET @colBitmap = SUBSTRING( COLUMNS_UPDATED(), 1, 1)
		ELSE
				SET @colBitmap = SUBSTRING( COLUMNS_UPDATED(), 2, 1) + SUBSTRING(Columns_UPDATED(), 1,1)
			WHILE @curColumnId <= @NumOfColumns
			BEGIN
				IF @colBitmap & POWER(2, (@curColumnId -1)) = POWER(2, (@curColumnId -1)) 
				BEGIN
					SET		@Value = NULL
					SELECT	@Property = name 
					FROM	sys.columns 
					WHERE	OBJECT_ID(''Documentation.' + @ViewName + ''') = object_id 
					AND		column_id = @curColumnId
					SELECT	@Value = Value 
					FROM	@Changes 
					WHERE	PropName = @Property 
					AND		SchemaName = @Schema
					AND		TabName = @Table
					IF EXISTS (SELECT * FROM ::fn_listextendedproperty(@Property, ''schema'', @schema, ''FUNCTION'', @Table, DEFAULT, DEFAULT))
					BEGIN
						IF @Value IS NULL OR DATALENGTH(@Value) = 0 
						BEGIN
							EXEC sp_dropextendedproperty  @Property, ''schema'', @schema, ''FUNCTION'', @Table, DEFAULT, DEFAULT
						END
						ELSE
						BEGIN
							EXEC sp_updateextendedproperty @Property,  @Value,  ''schema'', @schema, ''FUNCTION'', @Table, DEFAULT, DEFAULT
						END
					END
					ELSE
					BEGIN
						IF @Value IS NOT NULL AND DATALENGTH(@Value) > 0 
							EXEC sp_addextendedproperty @Property, @Value,  ''schema'', @Schema, ''FUNCTION'', @Table, DEFAULT, DEFAULT
					END
				END -- Change detected
				SET @curColumnId =@curColumnId + 1
			END
	FETCH NEXT FROM cDaten INTO @Schema, @Table
	END
	CLOSE cDaten
	DEALLOCATE cDaten
'
EXEC sp_executeSQL @SQLTrigger
IF @Debug = 1 PRINT @SQLTrigger
GO



CREATE  OR ALTER PROC	[Documentation].[GenerateExtendedColumnPropertiesView]
						@Debug bit = 0 
AS
SET NOCOUNT ON
DECLARE @SQLView nvarchar(max)	
DECLARE @SQLTrigger nvarchar(max)
DECLARE @SQLColumn nvarchar(max) = '', @SQLApply nvarchar(max) = ''
DECLARE @columnlist nvarchar(max)
DECLARE @ViewName nvarchar(255), @PropertyName nvarchar(255), @DisplayName nvarchar(255)
SET @ViewName = 'ExtendedColumnProperties'
DECLARE cProperties CURSOR LOCAL FAST_FORWARD FOR 
	SELECT propertyname --, displayname 
	FROM	Documentation.ExtendedPropertiesConfiguration 
	WHERE	objtype = 'COLUMN' 
	AND		includeinview = 1
	ORDER BY columnnumber
OPEN cProperties
FETCH NEXT FROM cProperties INTO @propertyName --, @DisplayName
WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @SQLColumn += ', CAST(' + QUOTENAME(@propertyName) + '.value AS nvarchar(4000))  ' + QUOTENAME(@PropertyName)
	SET @SQLApply += 'OUTER APPLY ::fn_listextendedproperty(''' + @PropertyName +  ''', ''schema'', SCHEMA_NAME(schema_id), CASE WHEN so.type = ''U'' THEN ''TABLE'' WHEN so.type = ''V'' THEN ''VIEW'' WHEN so.type IN (''TF'',''IF'') THEN ''FUNCTION'' ELSE ''UNKNOWN'' END  ,  so.name, ''COLUMN'', col.name)	' + QUOTENAME(@PropertyName) 
	SET @columnlist = ISNULL(@columnlist + ', ' + QUOTENAME(@PropertyName) , QUOTENAME(@PropertyName))
	FETCH NEXT FROM cProperties INTO @propertyName --, @DisplayName
END 
CLOSE cProperties
DEALLOCATE cProperties

SET @SQLView = 'CREATE OR ALTER VIEW [Documentation].' + QUOTENAME(@ViewName) + '
WITH VIEW_METADATA
AS
SELECT		CAST(SCHEMA_NAME(Schema_id) AS nvarchar(255))				[SCHEMA_NAME] , 
			CAST(so.name AS nvarchar(255))							    [OBJECT_NAME] , 
			CAST(col.name AS nvarchar(255))                             [COLUMN_NAME]'
SET @SQLView += @SQLColumn
SET @SQLView += '
FROM		sys.objects so
INNER JOIN	sys.columns col
ON			col.object_id = so.object_id
'
SET @SQLView += @SQLApply
SET @SQLView += ' WHERE so.type IN (''U'', ''V'', ''IF'', ''TF'') '
IF @Debug = 1 PRINT @SQLView
EXEC sp_executeSQL @SQLView 

SET @SQLTrigger = 'CREATE OR ALTER TRIGGER [Documentation].' + QUOTENAME( @ViewName + 'Trigger') + ' ON [Documentation].' + QUOTENAME(@ViewName) + '
INSTEAD OF UPDATE
AS
SET NOCOUNT ON
	DECLARE @colBitmap varbinary(2)
	DECLARE @NumOfColumns int
	DECLARE @Schema varchar(255)
	DECLARE @Property varchar(255)
	DECLARE @View sysname
	DECLARE @Column sysname
	DECLARE @Value SQL_VARIANT
	DECLARE @ObjectType varchar(255)
	DECLARE @Changes TABLE (schemaName sysname, tabName sysName,colname sysname,  Value SQL_VARIANT, PropName varchar(255))
	DECLARE @curColumnId int = 1
	INSERT INTO @Changes
		SELECT	*
		FROM	(SELECT	*	FROM	inserted i
				 UNPIVOT	(Res FOR Value IN ( ' + @columnlist + ') ) un ) un

	DECLARE cDaten CURSOR FAST_FORWARD FOR 
		SELECT		SCHEMA_NAME, 
					OBJECT_NAME, 
					COLUMN_NAME,
					CASE WHEN so.type IN (''U'') THEN ''TABLE'' WHEN so.type IN (''V'') THEN ''VIEW'' WHEN so.type IN (''IF'', ''TF'') THEN ''FUNCTION'' ELSE NULL END
		FROM		inserted i
		INNER JOIN  sys.objects SO
		ON			SO.name = OBJECT_NAME AND SCHEMA_NAME(so.SCHEMA_ID) = i.SCHEMA_NAME
	OPEN cDaten
	FETCH NEXT FROM cDaten INTO @Schema, @View, @Column, @ObjectType
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @curColumnId = 4	-- ignore first 3 columns
		SELECT @NumOfColumns = COUNT(*) FROM sys.columns WHERE OBJECT_ID(''Documentation.' + @ViewName + ''') = object_id
		IF @NumOfColumns < 9	
				SET @colBitmap = SUBSTRING( COLUMNS_UPDATED(), 1, 1)
		ELSE
				SET @colBitmap = SUBSTRING( COLUMNS_UPDATED(), 2, 1) + SUBSTRING(Columns_UPDATED(), 1,1)
			WHILE @curColumnId <= @NumOfColumns
			BEGIN
				IF @colBitmap & POWER(2, (@curColumnId -1)) = POWER(2, (@curColumnId -1)) 
				BEGIN
					SET		@Value = NULL
					SELECT	@Property = name 
					FROM	sys.columns 
					WHERE	OBJECT_ID(''Documentation.' + @ViewName + ''') = object_id 
					AND		column_id = @curColumnId
					SELECT	@Value = Value 
					FROM	@Changes 
					WHERE	PropName = @Property 
					AND		SchemaName = @Schema
					AND		TabName = @View
					AND		ColName = @Column
					IF EXISTS (SELECT * FROM ::fn_listextendedproperty(@Property, ''schema'', @schema, @ObjectType, @View, ''column'', @Column))
					BEGIN
						IF @Value IS NULL OR DATALENGTH(@Value) = 0 
						BEGIN
							EXEC sp_dropextendedproperty  @Property, ''schema'', @schema, @ObjectType, @View, ''column'', @Column
						END
						ELSE
						BEGIN
							EXEC sp_updateextendedproperty @Property,  @Value,  ''schema'', @schema, @ObjectType, @View, ''column'', @Column
						END
					END
					ELSE
					BEGIN
						IF @Value IS NOT NULL AND DATALENGTH(@Value) > 0 
							EXEC sp_addextendedproperty @Property, @Value,  ''SCHEMA'', @Schema, @ObjectType, @View, ''COLUMN'', @Column
					END
				END -- Change detected
				SET @curColumnId =@curColumnId + 1
			END
	FETCH NEXT FROM cDaten INTO @Schema, @View, @Column, @ObjectType
	END
	CLOSE cDaten
	DEALLOCATE cDaten
'
EXEC sp_executeSQL @SQLTrigger
IF @Debug = 1 PRINT @SQLTrigger
GO

CREATE  OR ALTER  PROC	[Documentation].[GenerateExtendedParameterPropertiesView]
						@Debug bit = 0 
AS
SET NOCOUNT ON
DECLARE @SQLView nvarchar(max)	
DECLARE @SQLTrigger nvarchar(max)
DECLARE @SQLColumn nvarchar(max) = '', @SQLApply nvarchar(max) = ''
DECLARE @columnlist nvarchar(max)
DECLARE @ViewName nvarchar(255), @PropertyName nvarchar(255), @DisplayName nvarchar(255)
SET @ViewName = 'ExtendedParameterProperties'
DECLARE cProperties CURSOR LOCAL FAST_FORWARD FOR 
	SELECT	propertyname --, displayname 
	FROM	Documentation.ExtendedPropertiesConfiguration 
	WHERE	objtype = 'COLUMN' 
	AND		includeinview = 1
	ORDER BY columnnumber
OPEN cProperties
FETCH NEXT FROM cProperties INTO @propertyName --, @DisplayName
WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @SQLColumn += ', CAST(' + QUOTENAME(@propertyName) + '.value AS nvarchar(4000))  ' + QUOTENAME(@PropertyName)
	SET @SQLApply += 'OUTER APPLY ::fn_listextendedproperty(''' + @PropertyName +  ''', ''schema'', SCHEMA_NAME(schema_id), CASE WHEN so.type = ''P'' THEN ''PROCEDURE'' WHEN so.type IN (''TF'',''IF'', ''FN'') THEN ''FUNCTION'' ELSE ''UNKNOWN'' END  ,  so.name, ''PARAMETER'', par.name)	' + QUOTENAME(@PropertyName) 
	SET @columnlist = ISNULL(@columnlist + ', ' + QUOTENAME(@PropertyName) , QUOTENAME(@PropertyName))
	FETCH NEXT FROM cProperties INTO @propertyName --, @DisplayName
END 
CLOSE cProperties
DEALLOCATE cProperties
SET @SQLView = 'CREATE OR ALTER VIEW [Documentation].' + QUOTENAME(@ViewName) + '
WITH VIEW_METADATA
AS
SELECT		CAST(CASE	WHEN type IN (''P'') THEN ''PROCEDURE''
					WHEN type IN (''IF'', ''FN'', ''TF'') THEN ''FUNCTION''
					ELSE ''UNKNOWN'' END	AS nvarchar(255))			[OBJECT_TYPE],
			CAST(SCHEMA_NAME(Schema_id) AS nvarchar(255))				[SCHEMA_NAME] , 
			CAST(so.name AS nvarchar(255))							    [OBJECT_NAME] , 
			CAST(par.name AS nvarchar(255))                				[PARAMETER_NAME]'

SET @SQLView += @SQLColumn
SET @SQLView += '
FROM		sys.objects so
INNER JOIN	sys.parameters par
ON			par.object_id = so.object_id
'
SET @SQLView += @SQLApply
SET @SQLView += ' WHERE so.type IN (''P'', ''FN'', ''IF'', ''TF'') AND Parameter_ID > 0' 
IF @Debug = 1 PRINT @SQLView
EXEC sp_executeSQL @SQLView 

SET @SQLTrigger = 'CREATE OR ALTER TRIGGER [Documentation].' + QUOTENAME( @ViewName + 'Trigger') + ' ON [Documentation].' + QUOTENAME(@ViewName) + '
INSTEAD OF UPDATE
AS
SET NOCOUNT ON
	DECLARE @colBitmap varbinary(2)
	DECLARE @NumOfColumns int
	DECLARE @Schema varchar(255)
	DECLARE @Property varchar(255)
	DECLARE @View sysname
	DECLARE @Parameter sysname
	DECLARE @Value SQL_VARIANT
	DECLARE @ObjectType varchar(255)
	DECLARE @Changes TABLE (objecttype sysname, schemaName sysname, tabName sysName,colname sysname,  Value SQL_VARIANT, PropName varchar(255))
	DECLARE @curColumnId int = 1
	INSERT INTO @Changes
		SELECT	*
		FROM	(SELECT	*	FROM	inserted i
				 UNPIVOT	(Res FOR Value IN ( ' + @columnlist + ') ) un ) un

	DECLARE cDaten CURSOR FAST_FORWARD FOR 
		SELECT		SCHEMA_NAME, 
					OBJECT_NAME, 
					NULLIF(PARAMETER_NAME, ''''),
					OBJECT_TYPE
		FROM		inserted i
		INNER JOIN  sys.objects SO
		ON			SO.name = OBJECT_NAME AND SCHEMA_NAME(so.SCHEMA_ID) = i.SCHEMA_NAME
	OPEN cDaten
	FETCH NEXT FROM cDaten INTO @Schema, @View, @Parameter, @ObjectType
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @curColumnId = 5	-- ignore first 4 columns
		SELECT @NumOfColumns = COUNT(*) FROM sys.columns WHERE OBJECT_ID(''Documentation.' + @ViewName + ''') = object_id
		IF @NumOfColumns < 9	
				SET @colBitmap = SUBSTRING( COLUMNS_UPDATED(), 1, 1)
		ELSE
				SET @colBitmap = SUBSTRING( COLUMNS_UPDATED(), 2, 1) + SUBSTRING(Columns_UPDATED(), 1,1)
			WHILE @curColumnId <= @NumOfColumns
			BEGIN
				IF @colBitmap & POWER(2, (@curColumnId -1)) = POWER(2, (@curColumnId -1)) 
				BEGIN

					SET		@Value = NULL
					SELECT	@Property = name 
					FROM	sys.columns 
					WHERE	OBJECT_ID(''Documentation.' + @ViewName + ''') = object_id 
					AND		column_id = @curColumnId
					SELECT	@Value = Value 
					FROM	@Changes 
					WHERE	PropName = @Property 
					AND		SchemaName = @Schema
					AND		TabName = @View
					AND		ColName = @Parameter
					IF EXISTS (SELECT * FROM ::fn_listextendedproperty(@Property, ''schema'', @schema, @ObjectType, @View, ''PARAMETER'', @Parameter))
					BEGIN
						IF @Value IS NULL OR DATALENGTH(@Value) = 0 
						BEGIN
							EXEC sp_dropextendedproperty  @Property, ''schema'', @schema, @ObjectType, @View, ''PARAMETER'', @Parameter
						END
						ELSE
						BEGIN
							EXEC sp_updateextendedproperty @Property,  @Value,  ''schema'', @schema, @ObjectType, @View, ''PARAMETER'', @Parameter
						END
					END
					ELSE
					BEGIN
						IF @Value IS NOT NULL AND DATALENGTH(@Value) > 0 
							EXEC sp_addextendedproperty @Property, @Value,  ''SCHEMA'', @Schema, @ObjectType, @View, ''PARAMETER'', @Parameter
					END
				END -- Change detected
				SET @curColumnId =@curColumnId + 1
			END
	FETCH NEXT FROM cDaten INTO @Schema, @View, @Parameter, @ObjectType
	END
	CLOSE cDaten
	DEALLOCATE cDaten
'
EXEC sp_executeSQL @SQLTrigger
IF @Debug = 1 PRINT @SQLTrigger
GO

CREATE  OR ALTER PROC	[Documentation].[GenerateExtendedForeignKeyPropertiesView]
						@Debug bit = 0 
AS
SET NOCOUNT ON
DECLARE @SQLView nvarchar(max)	
DECLARE @SQLTrigger nvarchar(max)
DECLARE @SQLColumn nvarchar(max) = '', @SQLApply nvarchar(max) = ''
DECLARE @columnlist nvarchar(max)
DECLARE @ViewName nvarchar(255), @PropertyName nvarchar(255), @DisplayName nvarchar(255)
SET @ViewName = 'ExtendedForeignKeyProperties'
DECLARE cProperties CURSOR LOCAL FAST_FORWARD FOR 
	SELECT propertyname --, displayname 
	FROM	Documentation.ExtendedPropertiesConfiguration 
	WHERE	objtype = 'CONSTRAINT' 
	AND		includeinview = 1
	ORDER BY columnnumber
OPEN cProperties
FETCH NEXT FROM cProperties INTO @propertyName --, @DisplayName
WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @SQLColumn += ', CAST(' + QUOTENAME(@propertyName) + '.value AS nvarchar(4000))  ' + QUOTENAME(@PropertyName)
	SET @SQLApply += 'OUTER APPLY ::fn_listextendedproperty(''' + @PropertyName +  ''', ''schema'', SCHEMA_NAME(tab.schema_id), ''TABLE'',  tab.name, ''CONSTRAINT'', fok.name)	' + QUOTENAME(@PropertyName) 
	SET @columnlist = ISNULL(@columnlist + ', ' + QUOTENAME(@PropertyName) , QUOTENAME(@PropertyName))
	FETCH NEXT FROM cProperties INTO @propertyName --, @DisplayName
END 
CLOSE cProperties
DEALLOCATE cProperties

SET @SQLView = 'CREATE OR ALTER VIEW [Documentation].' + QUOTENAME(@ViewName) + '
WITH VIEW_METADATA
AS
SELECT		CAST(SCHEMA_NAME(tab.Schema_id) AS nvarchar(255))				[SCHEMA_NAME] , 
			CAST(tab.name AS nvarchar(255))							    [OBJECT_NAME] , 
			CAST(fok.name AS nvarchar(255))                             [FOREIGNKEY_NAME]'
SET @SQLView += @SQLColumn
SET @SQLView += '
FROM		sys.tables tab
INNER JOIN	sys.foreign_keys fok
ON			tab.object_id = fok.parent_object_id
'
SET @SQLView += @SQLApply
--SET @SQLView += ' WHERE so.type IN (''U'', ''V'') '
IF @Debug = 1 PRINT @SQLView
EXEC sp_executeSQL @SQLView 

SET @SQLTrigger = 'CREATE OR ALTER TRIGGER [Documentation].' + QUOTENAME( @ViewName + 'Trigger') + ' ON [Documentation].' + QUOTENAME(@ViewName) + '
INSTEAD OF UPDATE
AS
SET NOCOUNT ON
	DECLARE @colBitmap varbinary(2)
	DECLARE @NumOfColumns int
	DECLARE @Schema varchar(255)
	DECLARE @Property varchar(255)
	DECLARE @View sysname
	DECLARE @forkey sysname
	DECLARE @Value SQL_VARIANT
	DECLARE @ObjectType varchar(255)
	DECLARE @curColumnIdd int
	DECLARE @Changes TABLE (schemaName sysname, tabName sysName, colname sysname,  Value SQL_VARIANT, PropName varchar(255))
	DECLARE @curColumnId int = 1
	INSERT INTO @Changes
		SELECT	*
		FROM	(SELECT	*	FROM	inserted i
				 UNPIVOT	(Res FOR Value IN ( ' + @columnlist + ') ) un ) un

	DECLARE cDaten CURSOR FAST_FORWARD FOR 
		SELECT		SCHEMA_NAME, 
					OBJECT_NAME, 
					FOREIGNKEY_NAME
		FROM		inserted i
		INNER JOIN  sys.objects SO
		ON			SO.name = OBJECT_NAME AND SCHEMA_NAME(so.SCHEMA_ID) = i.SCHEMA_NAME
	OPEN cDaten
	FETCH NEXT FROM cDaten INTO @Schema, @View, @forkey --, @ObjectType
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @curColumnId = 4	-- ignore first 3 columns
		SELECT @NumOfColumns = COUNT(*) FROM sys.columns WHERE OBJECT_ID(''Documentation.' + @ViewName + ''') = object_id
		IF @NumOfColumns < 9	
				SET @colBitmap = SUBSTRING( COLUMNS_UPDATED(), 1, 1)
		ELSE
				SET @colBitmap = SUBSTRING( COLUMNS_UPDATED(), 2, 1) + SUBSTRING(Columns_UPDATED(), 1,1)
			WHILE @curColumnId <= @NumOfColumns
			BEGIN
				IF @colBitmap & POWER(2, (@curColumnId -1)) = POWER(2, (@curColumnId -1)) 
				BEGIN
					SET		@Value = NULL
					SELECT	@Property = name 
					FROM	sys.columns 
					WHERE	OBJECT_ID(''Documentation.' + @ViewName + ''') = object_id 
					AND		column_id = @curColumnId
					SELECT	@Value = Value 
					FROM	@Changes 
					WHERE	PropName = @Property 
					AND		SchemaName = @Schema
					AND		TabName = @View
					AND		ColName = @forkey
					IF EXISTS (SELECT * FROM ::fn_listextendedproperty(@Property, ''schema'', @schema, ''TABLE'', @View, ''constraint'', @forkey))
					BEGIN
						IF @Value IS NULL OR DATALENGTH(@Value) = 0 
						BEGIN
							EXEC sp_dropextendedproperty  @Property, ''schema'', @schema, ''TABLE'', @View, ''constraint'', @forkey
						END
						ELSE
						BEGIN
							EXEC sp_updateextendedproperty @Property,  @Value,  ''schema'', @schema, ''TABLE'', @View, ''constraint'', @forkey
						END
					END
					ELSE
					BEGIN
						IF @Value IS NOT NULL AND DATALENGTH(@Value) > 0 
							EXEC sp_addextendedproperty @Property, @Value,  ''SCHEMA'', @Schema, ''TABLE'', @View, ''constraint'', @forkey
					END
				END -- Change detected
				SET @curColumnId =@curColumnId + 1
			END
	FETCH NEXT FROM cDaten INTO @Schema, @View, @forkey --, @ObjectType
	END
	CLOSE cDaten
	DEALLOCATE cDaten
'
EXEC sp_executeSQL @SQLTrigger
IF @Debug = 1 PRINT @SQLTrigger
GO

EXEC Documentation.GenerateExtendedTablePropertiesView 
EXEC Documentation.GenerateExtendedViewPropertiesView 
EXEC Documentation.GenerateExtendedProcedurePropertiesView 
EXEC Documentation.GenerateExtendedFunctionPropertiesView 
EXEC Documentation.GenerateExtendedForeignKeyPropertiesView 
EXEC Documentation.GenerateExtendedTriggerPropertiesView 
EXEC Documentation.GenerateExtendedParameterPropertiesView 
