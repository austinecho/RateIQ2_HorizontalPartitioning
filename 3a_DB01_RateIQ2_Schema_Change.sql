/*
DataTeam
RateIQ2 Partitioning

DBA:
-Monitor Transaction Logs and Blocking throughout process

•	DROP FK w/if exist
•	DROP PK w/if exist (Result Heap on all table in set)
•	ADD Partition Column and Back Fill Data
•	ALTER NULL Column and ADD DF 
•	ADD Clustered
•	ADD PK
•	ADD UX
•	ADD FK
•	Update Stats
	(The final state will be verified in a different step)

Run in DB01VPRD Equivilant 
*/
USE RateIQ2
GO

--===================================================================================================
--[START]
--===================================================================================================
PRINT '********************';
PRINT '!!! Script START !!!';
PRINT '********************';

IF ( SELECT @@SERVERNAME ) = 'DB01VPRD' BEGIN PRINT 'Running in Environment DB01VPRD...'; END;
ELSE IF ( SELECT @@SERVERNAME ) = 'QA4-DB01' BEGIN PRINT 'Running in Environment QA4-DB01...'; END;
ELSE IF ( SELECT @@SERVERNAME ) = 'DATATEAM4-DB01\DB01' BEGIN PRINT 'Running in Environment DATATEAM4-DB01\DB01...'; END;
ELSE BEGIN PRINT 'ERROR: Server name not found. Process stopped.'; RETURN; END;

--===================================================================================================
--[REMOVE ALL PKs]
--===================================================================================================
PRINT '***************************';
PRINT '*** Remove PK/Clustered ***';
PRINT '***************************';

--************************************************
PRINT 'Working on table [ChangeSet].[RatingDetail] ...';

IF EXISTS (   SELECT 1
              FROM   sys.objects
              WHERE  type_desc = 'PRIMARY_KEY_CONSTRAINT'
                AND  parent_object_id = OBJECT_ID( N'ChangeSet.RatingDetail' )
				AND  name = N'PK_RatingDetail'
          )
BEGIN    
	ALTER TABLE ChangeSet.RatingDetail DROP CONSTRAINT PK_RatingDetail;
    PRINT '- PK [PK_RatingDetail] Dropped';
END;

PRINT 'Working on table [Production].[RatingDetail] ...';

IF EXISTS (   SELECT 1
              FROM   sys.objects
              WHERE  type_desc = 'PRIMARY_KEY_CONSTRAINT'
                AND  parent_object_id = OBJECT_ID( N'Production.RatingDetail' )
				AND  name = N'PK_RatingDetail'
          )
BEGIN    
	ALTER TABLE Production.RatingDetail DROP CONSTRAINT PK_RatingDetail;
    PRINT '- PK [PK_RatingDetail] Dropped';
END;

PRINT 'Working on table [backup].[RatingDetail] ...';

IF EXISTS (   SELECT 1
              FROM   sys.objects
              WHERE  type_desc = 'PRIMARY_KEY_CONSTRAINT'
                AND  parent_object_id = OBJECT_ID( N'backup.RatingDetail' )
				AND  name = N'PK_RatingDetail'
          )
BEGIN    
	ALTER TABLE [backup].RatingDetail DROP CONSTRAINT PK_RatingDetail;
    PRINT '- PK [PK_RatingDetail] Dropped';
END;

--===================================================================================================
--[ALTER NULL COLUMN AND ADD DF]
--===================================================================================================
PRINT '************************************';
PRINT '*** Alter NULL Column And Add DF ***';
PRINT '************************************';

--******************************************************
PRINT 'Working on table [ChangeSet].[RatingDetail] ...';

IF EXISTS (   SELECT 1
                  FROM   sys.default_constraints
                  WHERE  name = 'DF_ChangeSet_RatingDetail_EffectiveDate'
                    AND  parent_object_id = OBJECT_ID( N'ChangeSet.RatingDetail' ))
BEGIN
    ALTER TABLE ChangeSet.RatingDetail DROP CONSTRAINT DF_ChangeSet_RatingDetail_EffectiveDate
    PRINT '- DF [DF_ChangeSet_RatingDetail_EffectiveDate] Dropped';
END;

IF EXISTS (   SELECT 1
              FROM   sys.columns
              WHERE  name = 'EffectiveDate'
                AND  object_id = OBJECT_ID( N'ChangeSet.RatingDetail' )
                AND  is_nullable = 1 )
BEGIN
    ALTER TABLE ChangeSet.RatingDetail ALTER COLUMN EffectiveDate DATETIME NOT NULL;
    PRINT '- Column [EffectiveDate] Changed to Not Null';
END;

IF NOT EXISTS (   SELECT 1
                  FROM   sys.default_constraints
                  WHERE  name = 'DF_ChangeSet_RatingDetail_EffectiveDate'
                    AND  parent_object_id = OBJECT_ID( N'ChangeSet.RatingDetail' ))
BEGIN
    ALTER TABLE ChangeSet.RatingDetail ADD CONSTRAINT DF_ChangeSet_RatingDetail_EffectiveDate DEFAULT GETDATE() FOR EffectiveDate;
    PRINT '- DF [DF_ChangeSet_RatingDetail_EffectiveDate] Created';
END;
GO

PRINT 'Working on table [Production].[RatingDetail] ...';
IF EXISTS (   SELECT 1
                  FROM   sys.default_constraints
                  WHERE  name = 'DF_Production_RatingDetail_EffectiveDate'
                    AND  parent_object_id = OBJECT_ID( N'Production.RatingDetail' ))
BEGIN
    ALTER TABLE Production.RatingDetail DROP CONSTRAINT DF_Production_RatingDetail_EffectiveDate
    PRINT '- DF [DF_Production_RatingDetail_EffectiveDate] Dropped';
END;

IF EXISTS (   SELECT 1
              FROM   sys.columns
              WHERE  name = 'EffectiveDate'
                AND  object_id = OBJECT_ID( N'Production.RatingDetail' )
                AND  is_nullable = 1 )
BEGIN
    ALTER TABLE Production.RatingDetail ALTER COLUMN EffectiveDate DATETIME NOT NULL;
    PRINT '- Column [EffectiveDate] Changed to Not Null';
END;

IF NOT EXISTS (   SELECT 1
                  FROM   sys.default_constraints
                  WHERE  name = 'DF_Production_RatingDetail_EffectiveDate'
                    AND  parent_object_id = OBJECT_ID( N'Production.RatingDetail' ))
BEGIN
    ALTER TABLE Production.RatingDetail ADD CONSTRAINT DF_Production_RatingDetail_EffectiveDate DEFAULT GETDATE() FOR EffectiveDate;
    PRINT '- DF [DF_Production_RatingDetail_EffectiveDate] Created';
END;
GO

PRINT 'Working on table [backup].[RatingDetail] ...';
IF EXISTS (   SELECT 1
                  FROM   sys.default_constraints
                  WHERE  name = 'DF_backup_RatingDetail_EffectiveDate'
                    AND  parent_object_id = OBJECT_ID( N'backup.RatingDetail' ))
BEGIN
    ALTER TABLE [backup].RatingDetail DROP CONSTRAINT DF_backup_RatingDetail_EffectiveDate
    PRINT '- DF [DF_backup_RatingDetail_EffectiveDate] Dropped';
END;

IF EXISTS (   SELECT 1
              FROM   sys.columns
              WHERE  name = 'EffectiveDate'
                AND  object_id = OBJECT_ID( N'backup.RatingDetail' )
                AND  is_nullable = 1 )
BEGIN
    ALTER TABLE [backup].RatingDetail ALTER COLUMN EffectiveDate DATETIME NOT NULL;
    PRINT '- Column [EffectiveDate] Changed to Not Null';
END;

IF NOT EXISTS (   SELECT 1
                  FROM   sys.default_constraints
                  WHERE  name = 'DF_backup_RatingDetail_EffectiveDate'
                    AND  parent_object_id = OBJECT_ID( N'backup.RatingDetail' ))
BEGIN
    ALTER TABLE [backup].RatingDetail ADD CONSTRAINT DF_backup_RatingDetail_EffectiveDate DEFAULT GETDATE() FOR EffectiveDate;
    PRINT '- DF [DF_backup_RatingDetail_EffectiveDate] Created';
END;
GO


--===================================================================================================
--[CREATE CLUSTERED INDEX]
--===================================================================================================
PRINT '******************************';
PRINT '*** Create Clustered Index ***';
PRINT '******************************';

--************************************************
PRINT 'Working on table [ChangeSet].[RatingDetail] ...';

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'CIX_ChangeSet_RatingDetail_EffectiveDate' )
BEGIN
    DROP INDEX CIX_ChangeSet_RatingDetail_EffectiveDate ON ChangeSet.RatingDetail;
	PRINT '- Index [CIX_ChangeSet_RatingDetail_EffectiveDate] Dropped';
END;

CREATE CLUSTERED INDEX CIX_ChangeSet_RatingDetail_EffectiveDate
ON ChangeSet.RatingDetail ( EffectiveDate ASC )
WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_RateIQ2_DATETIME_2Year(EffectiveDate);
PRINT '- Index [CIX_ChangeSet_RatingDetail_EffectiveDate] Created';

PRINT 'Working on table [Production].[RatingDetail] ...';
IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'CIX_Production_RatingDetail_EffectiveDate' )
BEGIN
    DROP INDEX CIX_Production_RatingDetail_EffectiveDate ON Production.RatingDetail;
	PRINT '- Index [CIX_Production_RatingDetail_EffectiveDate] Dropped';
END;

CREATE CLUSTERED INDEX CIX_Production_RatingDetail_EffectiveDate
ON Production.RatingDetail ( EffectiveDate ASC )
WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_RateIQ2_DATETIME_2Year(EffectiveDate);
PRINT '- Index [CIX_Production_RatingDetail_EffectiveDate] Created';

PRINT 'Working on table [backup].[RatingDetail] ...';
IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'CIX_backup_RatingDetail_EffectiveDate' )
BEGIN
    DROP INDEX CIX_backup_RatingDetail_EffectiveDate ON [backup].RatingDetail;
	PRINT '- Index [CIX_backup_RatingDetail_EffectiveDate] Dropped';
END;

CREATE CLUSTERED INDEX CIX_backup_RatingDetail_EffectiveDate
ON [backup].RatingDetail ( EffectiveDate ASC )
WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_RateIQ2_DATETIME_2Year(EffectiveDate);
PRINT '- Index [CIX_backup_RatingDetail_EffectiveDate] Created';


--===================================================================================================
--[CREATE PKs]
--===================================================================================================
PRINT '******************';
PRINT '*** Create PKs ***';
PRINT '******************';

--************************************************
PRINT 'Working on table [ChangeSet].[RatingDetail] ...';

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'PK_ChangeSet_RatingDetail_EffectiveDate_RatingDetailId' )
BEGIN
    ALTER TABLE ChangeSet.RatingDetail DROP CONSTRAINT PK_ChangeSet_RatingDetail_EffectiveDate_RatingDetailId;
	PRINT '- PK [PK_ChangeSet_RatingDetail_EffectiveDate_RatingDetailId] Dropped';
END;

ALTER TABLE ChangeSet.RatingDetail
ADD CONSTRAINT PK_ChangeSet_RatingDetail_EffectiveDate_RatingDetailId
    PRIMARY KEY NONCLUSTERED ( EffectiveDate, RatingDetailId)
    WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_RateIQ2_DATETIME_2Year(columnName);
PRINT '- PK [PK_ChangeSet_RatingDetail_EffectiveDate_RatingDetailId] Created';

PRINT 'Working on table [Production].[RatingDetail] ...';
IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'PK_Production_RatingDetail_EffectiveDate_RatingDetailId' )
BEGIN
    ALTER TABLE Production.RatingDetail DROP CONSTRAINT PK_Production_RatingDetail_EffectiveDate_RatingDetailId;
	PRINT '- PK [PK_Production_RatingDetail_EffectiveDate_RatingDetailId] Dropped';
END;

ALTER TABLE Production.RatingDetail
ADD CONSTRAINT PK_Production_RatingDetail_EffectiveDate_RatingDetailId
    PRIMARY KEY NONCLUSTERED ( EffectiveDate, RatingDetailId)
    WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_RateIQ2_DATETIME_2Year(columnName);
PRINT '- PK [PK_Production_RatingDetail_EffectiveDate_RatingDetailId] Created';

PRINT 'Working on table [backup].[RatingDetail] ...';
IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'PK_backup_RatingDetail_EffectiveDate_RatingDetailId' )
BEGIN
    ALTER TABLE [backup].RatingDetail DROP CONSTRAINT PK_backup_RatingDetail_EffectiveDate_RatingDetailId;
	PRINT '- PK [PK_backup_RatingDetail_EffectiveDate_RatingDetailId] Dropped';
END;

ALTER TABLE [backup].RatingDetail
ADD CONSTRAINT PK_backup_RatingDetail_EffectiveDate_RatingDetailId
    PRIMARY KEY NONCLUSTERED ( EffectiveDate, RatingDetailId)
    WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_RateIQ2_DATETIME_2Year(columnName);
PRINT '- PK [PK_backup_RatingDetail_EffectiveDate_RatingDetailId] Created';

--===================================================================================================
--[UPDATE STATS]
--===================================================================================================
PRINT '********************';
PRINT '*** Update Stats ***';
PRINT '********************';

--************************************************
PRINT 'Working on table [ChangeSet].[RatingDetail] ...';

UPDATE STATISTICS ChangeSet.RatingDetail;
PRINT '- Statistics Updated';

UPDATE STATISTICS [backup].RatingDetail;
PRINT '- Statistics Updated';

UPDATE STATISTICS Production.RatingDetail;
PRINT '- Statistics Updated';


--===================================================================================================
--[DONE]
--===================================================================================================
PRINT '***********************';
PRINT '!!! Script COMPLETE !!!';
PRINT '***********************';