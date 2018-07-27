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

IF ( SELECT @@SERVERNAME ) IN ('RATEIQSQL5','VMRATEIQ1','VMRATEIQ3','VMRATEIQ4') BEGIN PRINT 'Running in Environment RateIQ2ScaleOut...'; END;
ELSE IF ( SELECT @@SERVERNAME ) = 'VMQA3-RATEIQ2A.QA.ECHOGL.NET' BEGIN PRINT 'Running in Environment VMQA3-RATEIQ2A...'; END;
ELSE IF ( SELECT @@SERVERNAME ) = 'DATATEAM4-DB01\DB01' BEGIN PRINT 'Running in Environment DATATEAM4-DB01\DB01...'; END;
ELSE BEGIN PRINT 'ERROR: Server name not found. Process stopped.'; RETURN; END;

--===================================================================================================
--[REMOVE ALL INDEXES]
--===================================================================================================

IF EXISTS ( SELECT  1
            FROM    sys.sysindexes
            WHERE   name = 'IDX_Composite_RatingId_Org_Dest_EffDt_ExpDt_Direc_FrmWgt_ToWgt' )
    BEGIN
        DROP INDEX IDX_Composite_RatingId_Org_Dest_EffDt_ExpDt_Direc_FrmWgt_ToWgt ON Production.RatingDetail;
        PRINT '- Index [IDX_Composite_RatingId_Org_Dest_EffDt_ExpDt_Direc_FrmWgt_ToWgt] Dropped'; 
    END;
IF EXISTS ( SELECT  1
            FROM    sys.sysindexes
            WHERE   name = 'IDX_P_Composite_RatingId_Org_Dest_EffDt_ExpDt_Direc_FrmWgt_ToWgt' )
    BEGIN
        DROP INDEX IDX_P_Composite_RatingId_Org_Dest_EffDt_ExpDt_Direc_FrmWgt_ToWgt ON Production.RatingDetail;
        PRINT '- Index [IDX_P_Composite_RatingId_Org_Dest_EffDt_ExpDt_Direc_FrmWgt_ToWgt] Dropped'; 
    END;
IF EXISTS ( SELECT  1
            FROM    sys.sysindexes
            WHERE   name = 'idx_P_ratingid_includes' )
    BEGIN
        DROP INDEX idx_P_ratingid_includes ON Production.RatingDetail;
        PRINT '- Index [idx_P_ratingid_includes] Dropped'; 
    END;
IF EXISTS ( SELECT  1
            FROM    sys.sysindexes
            WHERE   name = 'IX_P_RatingDetail' )
    BEGIN
        DROP INDEX IX_P_RatingDetail ON Production.RatingDetail;
        PRINT '- Index [IX_P_RatingDetail] Dropped'; 
    END;
IF EXISTS ( SELECT  1
            FROM    sys.sysindexes
            WHERE   name = 'IX_P_RatingDetail_Bulk2' )
    BEGIN
        DROP INDEX IX_P_RatingDetail_Bulk2 ON Production.RatingDetail;
        PRINT '- Index [IX_P_RatingDetail_Bulk2] Dropped'; 
    END;
IF EXISTS ( SELECT  1
            FROM    sys.sysindexes
            WHERE   name = 'IX_P_RatingDetail_Bulk3' )
    BEGIN
        DROP INDEX IX_P_RatingDetail_Bulk3 ON Production.RatingDetail;
        PRINT '- Index [IX_P_RatingDetail_Bulk3] Dropped'; 
    END;
IF EXISTS ( SELECT  1
            FROM    sys.sysindexes
            WHERE   name = 'IX_P_RatingDetail_TariffPricingId' )
    BEGIN
        DROP INDEX IX_P_RatingDetail_TariffPricingId ON Production.RatingDetail;
        PRINT '- Index [IX_P_RatingDetail_TariffPricingId] Dropped'; 
    END;

--===================================================================================================
--[REMOVE ALL PKs]
--===================================================================================================
PRINT '***************************';
PRINT '*** Remove PK/Clustered ***';
PRINT '***************************';

--************************************************

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

--===================================================================================================
--[ALTER NULL COLUMN AND ADD DF]
--===================================================================================================
PRINT '************************************';
PRINT '*** Alter NULL Column And Add DF ***';
PRINT '************************************';

--******************************************************

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


--===================================================================================================
--[CREATE CLUSTERED INDEX]
--===================================================================================================
PRINT '******************************';
PRINT '*** Create Clustered Index ***';
PRINT '******************************';

--************************************************

PRINT 'Working on table [Production].[RatingDetail] ...';
IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'CIX_Production_RatingDetail_EffectiveDate' )
BEGIN
    DROP INDEX CIX_Production_RatingDetail_EffectiveDate ON Production.RatingDetail;
	PRINT '- Index [CIX_Production_RatingDetail_EffectiveDate] Dropped';
END;

CREATE CLUSTERED INDEX CIX_Production_RatingDetail_EffectiveDate
ON Production.RatingDetail ( EffectiveDate ASC )
WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON )
PRINT '- Index [CIX_Production_RatingDetail_EffectiveDate] Created';

--===================================================================================================
--[CREATE PKs]
--===================================================================================================
PRINT '******************';
PRINT '*** Create PKs ***';
PRINT '******************';

--************************************************

PRINT 'Working on table [Production].[RatingDetail] ...';
IF EXISTS ( SELECT 1 FROM sys.sysindexes WHERE name = 'PK_Production_RatingDetail_EffectiveDate_RatingDetailId' )
BEGIN
    ALTER TABLE Production.RatingDetail DROP CONSTRAINT PK_Production_RatingDetail_EffectiveDate_RatingDetailId;
	PRINT '- PK [PK_Production_RatingDetail_EffectiveDate_RatingDetailId] Dropped';
END;

ALTER TABLE Production.RatingDetail
ADD CONSTRAINT PK_Production_RatingDetail_EffectiveDate_RatingDetailId
    PRIMARY KEY NONCLUSTERED ( EffectiveDate, RatingDetailId)
    WITH ( SORT_IN_TEMPDB = ON, ONLINE = ON )
PRINT '- PK [PK_Production_RatingDetail_EffectiveDate_RatingDetailId] Created';


--===================================================================================================
--[CREATE INDEXES]
--===================================================================================================

IF EXISTS ( SELECT  1
            FROM    sys.sysindexes
            WHERE   name = 'IX_Production_RatingDetail_OriginId_DestinationId_FromWeight_ToWeight_EffectiveDate_ExpiryDate_RatingId_DirectionTypeId' )
    BEGIN
        DROP INDEX IX_Production_RatingDetail_OriginId_DestinationId_FromWeight_ToWeight_EffectiveDate_ExpiryDate_RatingId_DirectionTypeId ON Production.RatingDetail;
        PRINT '- Index [IX_Production_RatingDetail_OriginId_DestinationId_FromWeight_ToWeight_EffectiveDate_ExpiryDate_RatingId_DirectionTypeId] Dropped'; 
    END;

CREATE NONCLUSTERED INDEX IX_Production_RatingDetail_OriginId_DestinationId_FromWeight_ToWeight_EffectiveDate_ExpiryDate_RatingId_DirectionTypeId ON Production.RatingDetail
( OriginId, DestinationId, FromWeight, ToWeight, EffectiveDate, ExpiryDate, RatingId, DirectionTypeId);

IF EXISTS ( SELECT  1
            FROM    sys.sysindexes
            WHERE   name = 'IX_Production_RatingDetail_OriginId' )
    BEGIN
        DROP INDEX IX_Production_RatingDetail_OriginId ON Production.RatingDetail;
        PRINT '- Index [IX_Production_RatingDetail_OriginId] Dropped'; 
    END;

CREATE NONCLUSTERED INDEX IX_Production_RatingDetail_OriginId ON Production.RatingDetail
( OriginId);

IF EXISTS ( SELECT  1
            FROM    sys.sysindexes
            WHERE   name = 'IX_Production_RatingDetail_DestinationId' )
    BEGIN
        DROP INDEX IX_Production_RatingDetail_DestinationId ON Production.RatingDetail;
        PRINT '- Index [IX_Production_RatingDetail_DestinationId] Dropped'; 
    END;

CREATE NONCLUSTERED INDEX IX_Production_RatingDetail_DestinationId ON Production.RatingDetail
( DestinationId);

IF EXISTS ( SELECT  1
            FROM    sys.sysindexes
            WHERE   name = 'IX_Production_RatingDetail_RatingId_Incl' )
    BEGIN
        DROP INDEX IX_Production_RatingDetail_RatingId_Incl ON Production.RatingDetail;
        PRINT '- Index [IX_Production_RatingDetail_RatingId_Incl] Dropped'; 
    END;

CREATE NONCLUSTERED INDEX IX_Production_RatingDetail_RatingId_Incl ON Production.RatingDetail
( RatingId) INCLUDE (TariffPricingId);

IF EXISTS ( SELECT  1
            FROM    sys.sysindexes
            WHERE   name = 'IX_Production_RatingDetail_RatingId_EffectiveDate_FromWeight_FromMiles_DirectionTypeId' )
    BEGIN
        DROP INDEX IX_Production_RatingDetail_RatingId_EffectiveDate_FromWeight_FromMiles_DirectionTypeId ON Production.RatingDetail;
        PRINT '- Index [IX_Production_RatingDetail_RatingId_EffectiveDate_FromWeight_FromMiles_DirectionTypeId] Dropped'; 
    END;

CREATE NONCLUSTERED INDEX IX_Production_RatingDetail_RatingId_EffectiveDate_FromWeight_FromMiles_DirectionTypeId ON Production.RatingDetail
( RatingId, EffectiveDate, FromWeight, FromMiles, DirectionTypeId);

IF EXISTS ( SELECT  1
            FROM    sys.sysindexes
            WHERE   name = 'IX_Production_RatingDetail_TariffPricingId' )
    BEGIN
        DROP INDEX IX_Production_RatingDetail_TariffPricingId ON Production.RatingDetail;
        PRINT '- Index [IX_Production_RatingDetail_TariffPricingId] Dropped'; 
    END;

CREATE NONCLUSTERED INDEX IX_Production_RatingDetail_TariffPricingId ON Production.RatingDetail
( TariffPricingId);


--===================================================================================================
--[UPDATE STATS]
--===================================================================================================
PRINT '********************';
PRINT '*** Update Stats ***';
PRINT '********************';

--************************************************
PRINT 'Working on table [ChangeSet].[RatingDetail] ...';

UPDATE STATISTICS Production.RatingDetail;
PRINT '- Statistics Updated';


--===================================================================================================
--[DONE]
--===================================================================================================
PRINT '***********************';
PRINT '!!! Script COMPLETE !!!';
PRINT '***********************';