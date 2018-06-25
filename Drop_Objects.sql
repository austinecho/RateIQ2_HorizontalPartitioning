IF OBJECT_ID('tempdb..#Temp') IS NOT NULL
    DROP TABLE #Temp;

IF OBJECT_ID('tempdb..#OutPut') IS NOT NULL
    DROP TABLE #OutPut;

CREATE TABLE #Temp
    (
      OldName VARCHAR(200) ,
      NewName VARCHAR(200) ,
      TableName VARCHAR(200) ,
      ObjectType VARCHAR(20) ,
      IsProcessed BIT DEFAULT 0
    );

CREATE TABLE #OutPut
    (
      ID INT IDENTITY(1, 1) ,
      OutPut VARCHAR(MAX)
    );


INSERT  INTO #Temp
        ( OldName, NewName, TableName, ObjectType )
VALUES  ( 'FK_RatingDetail_BreakPricing_BreakPricingId',
          'FK_ChangeSet_RatingDetail_ChangeSet_BreakPricing_BreakPricingId',
          'ChangeSet.RatingDetail', 'FK' ),
        ( 'FK_RatingDetail_DirectionType_DirectionTypeId',
          'FK_ChangeSet_RatingDetail_ChangeSet_DirectionType_DirectionTypeId',
          'ChangeSet.RatingDetail', 'FK' ),
        ( 'FK_RatingDetail_Fak_FakId',
          'FK_ChangeSet_RatingDetail_ChangeSet_Fak_FakId',
          'ChangeSet.RatingDetail', 'FK' ),
        ( 'FK_RatingDetail_PointsType_PointsTypeId',
          'FK_ChangeSet_RatingDetail_ChangeSet_PointsType_PointsTypeId',
          'ChangeSet.RatingDetail', 'FK' ),
        ( 'FK_RatingDetail_Rating_RatingId',
          'FK_ChangeSet_RatingDetail_ChangeSet_Rating_RatingId',
          'ChangeSet.RatingDetail', 'FK' ),
        ( 'FK_RatingDetail_RatingType_RatingTypeId',
          'FK_ChangeSet_RatingDetail_ChangeSet_RatingType_RatingTypeId',
          'ChangeSet.RatingDetail', 'FK' ),
        ( 'FK_RatingDetail_TariffPricing_TariffPricingId',
          'FK_ChangeSet_RatingDetail_ChangeSet_TariffPricing_TariffPricingId',
          'ChangeSet.RatingDetail', 'FK' ),
        ( 'PK_RatingDetail',
          'PK_ChangeSet_RatingDetail_RatingDetailId_EffectiveDate',
          'ChangeSet.RatingDetail', 'PK' );


DECLARE @FKProcessedCount INT = ( SELECT    COUNT(1)
                                  FROM      #Temp
                                  WHERE     ObjectType = 'FK'
                                );
DECLARE @PKProcessedCount INT = ( SELECT    COUNT(1)
                                  FROM      #Temp
                                  WHERE     ObjectType = 'PK'
                                );
DECLARE @OldName VARCHAR(200);
DECLARE @NewName VARCHAR(200);
DECLARE @TableName VARCHAR(200);


--====================================================================================
-- Remove FK
--====================================================================================

IF @FKProcessedCount > 0
    BEGIN


INSERT  INTO #OutPut
SELECT  
'-- ===================================================================================================
-- [REMOVE FK]
-- ===================================================================================================
PRINT ''*****************'';
PRINT ''*** Remove FK ***'';
PRINT ''*****************'';';

        WHILE @FKProcessedCount > 0
            BEGIN

                SELECT  @OldName = OldName ,
                        @NewName = NewName ,
                        @TableName = TableName
                FROM    #Temp
                WHERE   IsProcessed = 0
                        AND ObjectType = 'FK';

                INSERT  INTO #OutPut
                        SELECT  'IF EXISTS (   SELECT 1
              FROM   sys.foreign_keys
              WHERE  name = ''' + @OldName + '''
                AND  parent_object_id = OBJECT_ID( N''' + @TableName + '''))
BEGIN
    ALTER TABLE ChangeSet.RatingDetail DROP CONSTRAINT ' + @OldName + ';
    PRINT ''- FK ' + @OldName + ' Dropped'';
END;
ELSE IF EXISTS (   SELECT 1
                   FROM   sys.foreign_keys
                   WHERE  name = ''' + @NewName + '''
                     AND  parent_object_id = OBJECT_ID( N''' + @TableName
                                + ''' ))
	BEGIN
	    ALTER TABLE ChangeSet.RatingDetail DROP CONSTRAINT ' + @NewName + ';
	    PRINT ''- FK [' + @NewName + '] Dropped'' ;
	END;
ELSE
BEGIN
    PRINT ''!! WARNING: Foreign Key not found !!'';
END;
GO';

                UPDATE  #Temp
                SET     IsProcessed = 1
                WHERE   OldName = @OldName
                        AND NewName = @NewName;

                SET @FKProcessedCount = ( SELECT    COUNT(1)
                                          FROM      #Temp
                                          WHERE     IsProcessed = 0
                                                    AND ObjectType = 'FK'
                                        );

            END;
    END;
--====================================================================================
-- Remove PK
--====================================================================================

IF @PKProcessedCount > 0
    BEGIN

INSERT  INTO #OutPut
SELECT  
'-- ===================================================================================================
-- [REMOVE PK]
-- ===================================================================================================
PRINT ''*****************'';
PRINT ''*** Remove PK ***'';
PRINT ''*****************'';';

        WHILE @PKProcessedCount > 0
            BEGIN

                SELECT  @OldName = OldName ,
                        @NewName = [NewName] ,
                        @TableName = TableName
                FROM    #Temp
                WHERE   IsProcessed = 0
                        AND ObjectType = 'PK';

                INSERT  INTO #OutPut
                        SELECT  'IF EXISTS (   SELECT 1
              FROM   sys.objects
              WHERE  type_desc = ''' + @OldName + '''
                AND  parent_object_id = OBJECT_ID( N''' + @TableName + ''')
				AND  name = N''' + @OldName + '''
          )
BEGIN    
	ALTER TABLE ChangeSet.RatingDetail DROP CONSTRAINT PK_tblLoadCustomer;
    PRINT ''- PK ' + @OldName + ' Dropped'';
END;
GO';

                UPDATE  #Temp
                SET     IsProcessed = 1
                WHERE   OldName = @OldName
                        AND NewName = @NewName;

                SET @PKProcessedCount = ( SELECT    COUNT(1)
                                          FROM      #Temp
                                          WHERE     IsProcessed = 0
                                                    AND ObjectType = 'PK'
                                        );

            END;
    END;

--====================================================================================
-- Final Output
--====================================================================================


SELECT  [OutPut]
FROM    #OutPut
ORDER BY ID;
