IF OBJECT_ID('tempdb..#TempFK') IS NOT NULL
    DROP TABLE #TempFK;

IF OBJECT_ID('tempdb..#FKOutPut') IS NOT NULL
    DROP TABLE #FKOutPut;

CREATE TABLE #TempFK
    (
      OldFK VARCHAR(200) ,
      NewFK VARCHAR(200) ,
	  TableName VARCHAR(200) ,
      IsProcessed BIT DEFAULT 0
    );

CREATE TABLE #FKOutPut ( FKOutPut VARCHAR(MAX) );


INSERT  INTO #TempFK
        ( OldFK, NewFK, TableName )
        VALUES
('FK_RatingDetail_BreakPricing_BreakPricingId',	'FK_ChangeSet_RatingDetail_ChangeSet_BreakPricing_BreakPricingId',	'ChangeSet.RatingDetail'),
('FK_RatingDetail_DirectionType_DirectionTypeId',	'FK_ChangeSet_RatingDetail_ChangeSet_DirectionType_DirectionTypeId',	'ChangeSet.RatingDetail'),
('FK_RatingDetail_Fak_FakId',	'FK_ChangeSet_RatingDetail_ChangeSet_Fak_FakId',	'ChangeSet.RatingDetail'),
('FK_RatingDetail_PointsType_PointsTypeId',	'FK_ChangeSet_RatingDetail_ChangeSet_PointsType_PointsTypeId',	'ChangeSet.RatingDetail'),
('FK_RatingDetail_Rating_RatingId',	'FK_ChangeSet_RatingDetail_ChangeSet_Rating_RatingId',	'ChangeSet.RatingDetail'),
('FK_RatingDetail_RatingType_RatingTypeId',	'FK_ChangeSet_RatingDetail_ChangeSet_RatingType_RatingTypeId',	'ChangeSet.RatingDetail'),
('FK_RatingDetail_TariffPricing_TariffPricingId',	'FK_ChangeSet_RatingDetail_ChangeSet_TariffPricing_TariffPricingId',	'ChangeSet.RatingDetail')



DECLARE @ProcessedCount INT = 1;

INSERT INTO #FKOutPut
SELECT '-- ===================================================================================================
-- [REMOVE FK]
-- ===================================================================================================
PRINT ''*****************'';
PRINT ''*** Remove FK ***'';
PRINT ''*****************'';
-- ===================================================================================================
-- [REMOVE FK]
-- ===================================================================================================
PRINT ''*****************'';
PRINT ''*** Remove FK ***'';
PRINT ''*****************'';'

WHILE @ProcessedCount > 0
    BEGIN

        DECLARE @OldFK VARCHAR(200);
        DECLARE @NewFK VARCHAR(200);
		DECLARE @TableName VARCHAR(200);

        SELECT  @OldFK = OldFK ,
                @NewFK = NewFK ,
				@TableName = TableName
        FROM    #TempFK
        WHERE   IsProcessed = 0;

        INSERT  INTO #FKOutPut
                SELECT  'IF EXISTS (   SELECT 1
              FROM   sys.foreign_keys
              WHERE  name = ''' + @OldFK
                        + '''
                AND  parent_object_id = OBJECT_ID( N''' + @TableName
                        + '''))
BEGIN
    ALTER TABLE ChangeSet.RatingDetail DROP CONSTRAINT ' + @OldFK + ';
    PRINT ''- FK ' + @OldFK + ' Dropped'';
END;
ELSE IF EXISTS (   SELECT 1
                   FROM   sys.foreign_keys
                   WHERE  name = ''' + @NewFK
                        + '''
                     AND  parent_object_id = OBJECT_ID( N''' + @TableName
                        + ''' ))
	BEGIN
	    ALTER TABLE ChangeSet.RatingDetail DROP CONSTRAINT ' + @NewFK + ';
	    PRINT ''- FK [' + @NewFK + '] Dropped'' ;
	END;
ELSE
BEGIN
    PRINT ''!! WARNING: Foreign Key not found !!'';
END;
GO';

        UPDATE  #TempFK
        SET     IsProcessed = 1
        WHERE   OldFK = @OldFK
                AND NewFK = @NewFK;

        SET @ProcessedCount = ( SELECT  COUNT(1)
                                FROM    #TempFK
                                WHERE   IsProcessed = 0
                              );

    END;

SELECT  FKOutPut
FROM    #FKOutPut;

