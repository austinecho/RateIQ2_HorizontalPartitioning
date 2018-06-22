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


-- ===================================================================================================
-- [REMOVE FK]
-- ===================================================================================================
PRINT '*****************';
PRINT '*** Remove FK ***';
PRINT '*****************';


--************************************************
PRINT 'Working on table [ChangeSet].[RatingDetail] ...'; 

IF EXISTS (   SELECT 1
              FROM   sys.foreign_keys
              WHERE  name = 'FK_RatingDetail_TariffPricing_TariffPricingId'
                AND  parent_object_id = OBJECT_ID( N'ChangeSet.RatingDetail'))
BEGIN
    ALTER TABLE ChangeSet.RatingDetail DROP CONSTRAINT FK_RatingDetail_TariffPricing_TariffPricingId;
    PRINT '- FK FK_RatingDetail_TariffPricing_TariffPricingId Dropped';
END;
ELSE IF EXISTS (   SELECT 1
                   FROM   sys.foreign_keys
                   WHERE  name = 'FK_ChangeSet_RatingDetail_ChangeSet_TariffPricing_TariffPricingId'
                     AND  parent_object_id = OBJECT_ID( N'ChangeSet.RatingDetail' ))
	BEGIN
	    ALTER TABLE ChangeSet.RatingDetail DROP CONSTRAINT FK_ChangeSet_RatingDetail_ChangeSet_TariffPricing_TariffPricingId;
	    PRINT '- FK [FK_ChangeSet_RatingDetail_ChangeSet_TariffPricing_TariffPricingId] Dropped' ;
	END;
ELSE
BEGIN
    PRINT '!! WARNING: Foreign Key not found !!';
END;
GO
IF EXISTS (   SELECT 1
              FROM   sys.foreign_keys
              WHERE  name = 'FK_RatingDetail_RatingType_RatingTypeId'
                AND  parent_object_id = OBJECT_ID( N'ChangeSet.RatingDetail'))
BEGIN
    ALTER TABLE ChangeSet.RatingDetail DROP CONSTRAINT FK_RatingDetail_RatingType_RatingTypeId;
    PRINT '- FK FK_RatingDetail_RatingType_RatingTypeId Dropped';
END;
ELSE IF EXISTS (   SELECT 1
                   FROM   sys.foreign_keys
                   WHERE  name = 'FK_ChangeSet_RatingDetail_ChangeSet_RatingType_RatingTypeId'
                     AND  parent_object_id = OBJECT_ID( N'ChangeSet.RatingDetail' ))
	BEGIN
	    ALTER TABLE ChangeSet.RatingDetail DROP CONSTRAINT FK_ChangeSet_RatingDetail_ChangeSet_RatingType_RatingTypeId;
	    PRINT '- FK [FK_ChangeSet_RatingDetail_ChangeSet_RatingType_RatingTypeId] Dropped' ;
	END;
ELSE
BEGIN
    PRINT '!! WARNING: Foreign Key not found !!';
END;
GO
IF EXISTS (   SELECT 1
              FROM   sys.foreign_keys
              WHERE  name = 'FK_RatingDetail_Rating_RatingId'
                AND  parent_object_id = OBJECT_ID( N'ChangeSet.RatingDetail'))
BEGIN
    ALTER TABLE ChangeSet.RatingDetail DROP CONSTRAINT FK_RatingDetail_Rating_RatingId;
    PRINT '- FK FK_RatingDetail_Rating_RatingId Dropped';
END;
ELSE IF EXISTS (   SELECT 1
                   FROM   sys.foreign_keys
                   WHERE  name = 'FK_ChangeSet_RatingDetail_ChangeSet_Rating_RatingId'
                     AND  parent_object_id = OBJECT_ID( N'ChangeSet.RatingDetail' ))
	BEGIN
	    ALTER TABLE ChangeSet.RatingDetail DROP CONSTRAINT FK_ChangeSet_RatingDetail_ChangeSet_Rating_RatingId;
	    PRINT '- FK [FK_ChangeSet_RatingDetail_ChangeSet_Rating_RatingId] Dropped' ;
	END;
ELSE
BEGIN
    PRINT '!! WARNING: Foreign Key not found !!';
END;
GO
IF EXISTS (   SELECT 1
              FROM   sys.foreign_keys
              WHERE  name = 'FK_RatingDetail_PointsType_PointsTypeId'
                AND  parent_object_id = OBJECT_ID( N'ChangeSet.RatingDetail'))
BEGIN
    ALTER TABLE ChangeSet.RatingDetail DROP CONSTRAINT FK_RatingDetail_PointsType_PointsTypeId;
    PRINT '- FK FK_RatingDetail_PointsType_PointsTypeId Dropped';
END;
ELSE IF EXISTS (   SELECT 1
                   FROM   sys.foreign_keys
                   WHERE  name = 'FK_ChangeSet_RatingDetail_ChangeSet_PointsType_PointsTypeId'
                     AND  parent_object_id = OBJECT_ID( N'ChangeSet.RatingDetail' ))
	BEGIN
	    ALTER TABLE ChangeSet.RatingDetail DROP CONSTRAINT FK_ChangeSet_RatingDetail_ChangeSet_PointsType_PointsTypeId;
	    PRINT '- FK [FK_ChangeSet_RatingDetail_ChangeSet_PointsType_PointsTypeId] Dropped' ;
	END;
ELSE
BEGIN
    PRINT '!! WARNING: Foreign Key not found !!';
END;
GO
IF EXISTS (   SELECT 1
              FROM   sys.foreign_keys
              WHERE  name = 'FK_RatingDetail_Fak_FakId'
                AND  parent_object_id = OBJECT_ID( N'ChangeSet.RatingDetail'))
BEGIN
    ALTER TABLE ChangeSet.RatingDetail DROP CONSTRAINT FK_RatingDetail_Fak_FakId;
    PRINT '- FK FK_RatingDetail_Fak_FakId Dropped';
END;
ELSE IF EXISTS (   SELECT 1
                   FROM   sys.foreign_keys
                   WHERE  name = 'FK_ChangeSet_RatingDetail_ChangeSet_Fak_FakId'
                     AND  parent_object_id = OBJECT_ID( N'ChangeSet.RatingDetail' ))
	BEGIN
	    ALTER TABLE ChangeSet.RatingDetail DROP CONSTRAINT FK_ChangeSet_RatingDetail_ChangeSet_Fak_FakId;
	    PRINT '- FK [FK_ChangeSet_RatingDetail_ChangeSet_Fak_FakId] Dropped' ;
	END;
ELSE
BEGIN
    PRINT '!! WARNING: Foreign Key not found !!';
END;
GO
IF EXISTS (   SELECT 1
              FROM   sys.foreign_keys
              WHERE  name = 'FK_RatingDetail_DirectionType_DirectionTypeId'
                AND  parent_object_id = OBJECT_ID( N'ChangeSet.RatingDetail'))
BEGIN
    ALTER TABLE ChangeSet.RatingDetail DROP CONSTRAINT FK_RatingDetail_DirectionType_DirectionTypeId;
    PRINT '- FK FK_RatingDetail_DirectionType_DirectionTypeId Dropped';
END;
ELSE IF EXISTS (   SELECT 1
                   FROM   sys.foreign_keys
                   WHERE  name = 'FK_ChangeSet_RatingDetail_ChangeSet_DirectionType_DirectionTypeId'
                     AND  parent_object_id = OBJECT_ID( N'ChangeSet.RatingDetail' ))
	BEGIN
	    ALTER TABLE ChangeSet.RatingDetail DROP CONSTRAINT FK_ChangeSet_RatingDetail_ChangeSet_DirectionType_DirectionTypeId;
	    PRINT '- FK [FK_ChangeSet_RatingDetail_ChangeSet_DirectionType_DirectionTypeId] Dropped' ;
	END;
ELSE
BEGIN
    PRINT '!! WARNING: Foreign Key not found !!';
END;
GO
IF EXISTS (   SELECT 1
              FROM   sys.foreign_keys
              WHERE  name = 'FK_RatingDetail_BreakPricing_BreakPricingId'
                AND  parent_object_id = OBJECT_ID( N'ChangeSet.RatingDetail'))
BEGIN
    ALTER TABLE ChangeSet.RatingDetail DROP CONSTRAINT FK_RatingDetail_BreakPricing_BreakPricingId;
    PRINT '- FK FK_RatingDetail_BreakPricing_BreakPricingId Dropped';
END;
ELSE IF EXISTS (   SELECT 1
                   FROM   sys.foreign_keys
                   WHERE  name = 'FK_ChangeSet_RatingDetail_ChangeSet_BreakPricing_BreakPricingId'
                     AND  parent_object_id = OBJECT_ID( N'ChangeSet.RatingDetail' ))
	BEGIN
	    ALTER TABLE ChangeSet.RatingDetail DROP CONSTRAINT FK_ChangeSet_RatingDetail_ChangeSet_BreakPricing_BreakPricingId;
	    PRINT '- FK [FK_ChangeSet_RatingDetail_ChangeSet_BreakPricing_BreakPricingId] Dropped' ;
	END;
ELSE
BEGIN
    PRINT '!! WARNING: Foreign Key not found !!';
END;
GO


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
				AND  name = N'PUT PK NAME HERE'
          )
BEGIN    
	ALTER TABLE ChangeSet.RatingDetail DROP CONSTRAINT PK_tblLoadCustomer;
    PRINT '- PK [PUT PK NAME HERE] Dropped';
END;


--===================================================================================================
--[ADD PARTITION COLUMNs]
--===================================================================================================
--PRINT '*****************************';
--PRINT '*** Add Partition Columns ***';
--PRINT '*****************************';

----************************************************
--PRINT 'Working on table [ChangeSet].[RatingDetail] ...';

--IF NOT EXISTS (	SELECT 1
--				FROM sys.columns
--				WHERE name = 'CreatedDate'
--				AND object_id = OBJECT_ID(N'ChangeSet.RatingDetail'))
--BEGIN
--	ALTER TABLE ChangeSet.RatingDetail
--	ADD CreatedDate DATETIME NULL
--	PRINT '- Column [CreatedDate] Created';
--END;
--GO


--===================================================================================================
--[BACK FILL DATA]
--===================================================================================================
--PRINT '**********************';
--PRINT '*** Back Fill Data ***';
--PRINT '**********************';

----************************************************
--PRINT 'Working on table [ChangeSet].[RatingDetail] ...';

--BEGIN TRY
--	IF OBJECT_ID('tempdb..#LoadStopCreatedDate') IS NOT	NULL DROP TABLE #LoadStopCreatedDate;
--	CREATE TABLE #LoadStopCreatedDate (LoadStopCreatedDateID INT IDENTITY(1,1) PRIMARY KEY, LoadStopID INT, CreatedDate DATETIME);

--	WITH FirstLoadStopDate AS
--	(
--		SELECT LoadCustomerID, MIN(StopDate) AS StopDate
--		FROM ChangeSet.RatingDetail
--		GROUP BY LoadCustomerID
--		HAVING MIN(StopDate) IS NOT NULL
--	)
--	INSERT INTO #LoadStopCreatedDate(LoadStopID, CreatedDate)
--	SELECT ls.LoadStopID, CASE WHEN ls.StopDate IS NULL THEN flsd.StopDate ELSE ls.StopDate END AS CreatedDate
--	FROM ChangeSet.RatingDetail ls
--	INNER JOIN FirstLoadStopDate flsd ON ls.LoadCustomerID = flsd.LoadCustomerID

--	CREATE NONCLUSTERED INDEX IX_#LoadStopCreatedDate_LoadStopID_Incl
--	ON #LoadStopCreatedDate (LoadStopID)
--	INCLUDE (CreatedDate)

--	DECLARE @BatchCt INT;
--	DECLARE @LoopCt INT;
--	DECLARE @LoopMax INT;

--	SET @BatchCt = 500000
--	SET @LoopCt = ((SELECT MIN(LoadStopCreatedDateID) FROM #LoadStopCreatedDate)-1)
--	SET @LoopMax = (SELECT MAX(LoadStopCreatedDateID) FROM #LoadStopCreatedDate)

--	WHILE @LoopCt < @LoopMax
--	BEGIN
--		BEGIN TRANSACTION

--		UPDATE ls
--		SET ls.CreatedDate = lscd.CreatedDate
--		FROM ChangeSet.RatingDetail ls
--		INNER JOIN #LoadStopCreatedDate lscd ON ls.LoadStopID = lscd.LoadStopID
--		WHERE lscd.LoadStopCreatedDateID BETWEEN @LoopCt + 1 AND @LoopCt + @BatchCt;

--		SET @LoopCt = @LoopCt + @BatchCt

--		COMMIT TRANSACTION
--	END
	
--	BEGIN TRANSACTION
--		UPDATE ChangeSet.RatingDetail
--		SET CreatedDate = '1753-01-01 00:00:00.000'
--		WHERE CreatedDate IS NULL

--		UPDATE ChangeSet.tblLoadCustomer
--		SET CreateDate = '1753-01-01 00:00:00.000'
--		WHERE CreateDate IS NULL
--	COMMIT TRANSACTION
	
--	PRINT '- Back fill data Done';
--END TRY
--BEGIN CATCH
--	IF @@TRANCOUNT > 0
--	BEGIN
--		ROLLBACK TRANSACTION;
--	END;

--	THROW;
--END CATCH;


--===================================================================================================
--[ALTER NULL COLUMN AND ADD DF]
--===================================================================================================
PRINT '************************************';
PRINT '*** Alter NULL Column And Add DF ***';
PRINT '************************************';

--******************************************************
PRINT 'Working on table [ChangeSet].[tblLoadCustomer] ...';

IF EXISTS (   SELECT 1
                  FROM   sys.default_constraints
                  WHERE  name = 'CONSTRAINT NAME'
                    AND  parent_object_id = OBJECT_ID( N'ChangeSet.RatingDetail' ))
BEGIN
    ALTER TABLE ChangeSet.RatingDetail DROP CONSTRAINT CONSTRAINTNAME
    PRINT '- DF [CONSTRAINT NAME] Dropped';
END;

IF EXISTS (   SELECT 1
              FROM   sys.columns
              WHERE  name = 'columnName'
                AND  object_id = OBJECT_ID( N'ChangeSet.RatingDetail' )
                AND  is_nullable = 1 )
BEGIN
    ALTER TABLE ChangeSet.RatingDetail ALTER COLUMN columnName DATETIME NOT NULL;
    PRINT '- Column [columnName] Changed to Not Null';
END;

IF NOT EXISTS (   SELECT 1
                  FROM   sys.default_constraints
                  WHERE  name = 'CONSTRAINT NAME'
                    AND  parent_object_id = OBJECT_ID( N'ChangeSet.RatingDetail' ))
BEGIN
    ALTER TABLE ChangeSet.RatingDetail ADD CONSTRAINT CONSTRAINTNAME DEFAULT GETDATE() FOR columnName;
    PRINT '- DF [CONSTRAINT NAME] Created';
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

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'CIX_RatingDetail_columnName' )
BEGIN
    DROP INDEX CIX_RatingDetail_columnName ON ChangeSet.RatingDetail;
	PRINT '- Index [CIX_RatingDetail_columnName] Dropped';
END;

CREATE CLUSTERED INDEX CIX_RatingDetail_columnName
ON ChangeSet.RatingDetail ( columnName ASC )
WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_RateIQ2_partitionColumnType_partitionRange(columnName);
PRINT '- Index [CIX_RatingDetail_columnName] Created';


--===================================================================================================
--[CREATE PKs]
--===================================================================================================
PRINT '******************';
PRINT '*** Create PKs ***';
PRINT '******************';

--************************************************
PRINT 'Working on table [ChangeSet].[RatingDetail] ...';

IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'PK_RatingDetail_originalPrimaryKeyColumnName_columnName' )
BEGIN
    ALTER TABLE ChangeSet.RatingDetail DROP CONSTRAINT PK_RatingDetail_originalPrimaryKeyColumnName_columnName;
	PRINT '- PK [PK_RatingDetail_originalPrimaryKeyColumnName_columnName] Dropped';
END;

ALTER TABLE ChangeSet.RatingDetail
ADD CONSTRAINT PK_RatingDetail_originalPrimaryKeyColumnName_columnName
    PRIMARY KEY NONCLUSTERED ( originalPrimaryKeyColumnName, columnName)
    WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON PS_RateIQ2_partitionColumnType_partitionRange(columnName);
PRINT '- PK [PK_RatingDetail_originalPrimaryKeyColumnName_columnName] Created';


--===================================================================================================
--[CREATE UX]
--===================================================================================================
--PRINT '***************************';
--PRINT '*** Create Unique Index ***';
--PRINT '***************************';

----************************************************
--PRINT 'Working on table [ChangeSet].[tblLoadCustomer] ...';

--IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'UX_tblLoadCustomer_LoadCustomerID' )
--BEGIN
--    DROP INDEX UX_tblLoadCustomer_LoadCustomerID ON ChangeSet.tblLoadCustomer;
--	PRINT '- Index [UX_tblLoadCustomer_LoadCustomerID] Dropped';
--END;

--CREATE UNIQUE NONCLUSTERED INDEX UX_tblLoadCustomer_LoadCustomerID
--ON ChangeSet.tblLoadCustomer ( LoadCustomerID )
--WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON ) ON [PRIMARY];
--PRINT '- Index [UX_tblLoadCustomer_LoadCustomerID] Created';
--GO


--===================================================================================================
--[CREATE FK]
--===================================================================================================
--PRINT '*****************';
--PRINT '*** Create FK ***';
--PRINT '*****************';

----*****************************************************
--PRINT 'Working on table [ChangeSet].[RatingDetail] ...';

--ALTER TABLE ChangeSet.RatingDetail WITH NOCHECK
--ADD CONSTRAINT FK_RatingDetail_tblLoadCustomer_LoadCustomerID
--    FOREIGN KEY ( LoadCustomerID )
--    REFERENCES ChangeSet.tblLoadCustomer ( LoadCustomerID ) 
--	ON DELETE CASCADE
--	ON UPDATE CASCADE;
--PRINT '- FK [FK_RatingDetail_tblLoadCustomer_LoadCustomerID] Created';

--ALTER TABLE ChangeSet.RatingDetail CHECK CONSTRAINT FK_RatingDetail_tblLoadCustomer_LoadCustomerID;
--PRINT '- FK [FK_RatingDetail_tblLoadCustomer_LoadCustomerID] Enabled';
--GO

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


--===================================================================================================
--[DONE]
--===================================================================================================
PRINT '***********************';
PRINT '!!! Script COMPLETE !!!';
PRINT '***********************';