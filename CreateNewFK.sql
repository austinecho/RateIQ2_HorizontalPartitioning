DECLARE @TableNameFind VARCHAR(128) = 'RatingDetail'

IF OBJECT_ID('tempdb..#FKs') IS NOT NULL
    DROP TABLE #FKs;

   CREATE TABLE #FKs 
   (ID INT IDENTITY(1,1),
	FKName VARCHAR(128),
	SchemaName VARCHAR(128),
	TableName VARCHAR(128),
	ColumnName VARCHAR(128),
	ReferenceSchemaName VARCHAR(128),
	ReferenceTableName VARCHAR(128),
	ReferenceColumnName VARCHAR(128),
	IsProcessed BIT DEFAULT 0
   )

   INSERT INTO #FKs
           ( FKName ,
             SchemaName ,
             TableName ,
             ColumnName ,
			 ReferenceSchemaName,
             ReferenceTableName ,
             ReferenceColumnName
           )
SELECT DISTINCT f.name AS ForeignKey, 
   PrimS.name AS SchemaName,
   PrimT.name AS TableName, 
   COL_NAME(fc.parent_object_id, fc.parent_column_id) AS ColumnName, 
   RefS.name AS ReferenceSchemaName,
   RefT.name AS ReferenceTableName, 
   COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS ReferenceColumnName 
FROM sys.foreign_keys AS f 
INNER JOIN sys.foreign_key_columns AS fc 
   ON f.OBJECT_ID = fc.constraint_object_id
   INNER JOIN sys.tables AS PrimT ON F.parent_object_id = PrimT.object_id 
   INNER JOIN sys.tables AS RefT ON F.referenced_object_id = RefT.object_id
   INNER JOIN sys.schemas AS PrimS ON PrimT.schema_id = PrimS.schema_id
   INNER JOIN sys.schemas AS RefS ON RefT.schema_id = RefS.schema_id
   WHERE OBJECT_NAME(f.parent_object_id) = @TableNameFind


DECLARE @ProcessCount INT = 1

IF OBJECT_ID('tempdb..#CreateFK') IS NOT NULL
    DROP TABLE #CreateFK;
CREATE TABLE #CreateFK
(
	Script VARCHAR(MAX)
)

WHILE @ProcessCount > 0
BEGIN
   DECLARE @ID INT
   DECLARE @SchemaName VARCHAR(128)
   DECLARE @TableName VARCHAR(128)
   DECLARE @FKName VARCHAR(128)
   DECLARE @NewFKName VARCHAR(128)
   DECLARE @ColumnName VARCHAR(128)
   DECLARE @ReferenceSchemaName VARCHAR(128)
   DECLARE @ReferenceTableName VARCHAR(128)
   DECLARE @ReferenceColumnName VARCHAR(128)

SELECT TOP 1 @SchemaName = SchemaName, @TableName = TableName, @ColumnName = ColumnName, @ReferenceSchemaName = ReferenceSchemaName, @ReferenceTableName = ReferenceTableName, @ReferenceColumnName = ColumnName,
@ID = ID
FROM #FKs
WHERE IsProcessed = 0

SET @NewFKName = 'FK_' + @SchemaName + '_' + @TableName + '_' + @ReferenceSchemaName + '_' + @ReferenceTableName + '_' + @ReferenceColumnName 

INSERT INTO #CreateFK
        ( Script )
SELECT'
   ALTER TABLE ' + @SchemaName  + '.' + @TableName + ' WITH NOCHECK
ADD CONSTRAINT ' + @NewFKName + '
    FOREIGN KEY ( ' + @ColumnName +' )
    REFERENCES ' + @ReferenceSchemaName + '.' + @ReferenceTableName + '(' + @ReferenceColumnName + ' ) 
PRINT ''- FK [' + @NewFKName + '] Created'';

ALTER TABLE ' + @SchemaName + '.' + @TableName + ' CHECK CONSTRAINT ' + @NewFKName + ';
PRINT ''- FK [' + @NewFKName + '] Enabled'';
GO'


UPDATE #FKs
SET IsProcessed = 1
WHERE ID = @ID

SET @ProcessCount = (SELECT COUNT(1) FROM #FKs WHERE IsProcessed = 0)

END

SELECT Script
FROM #CreateFK