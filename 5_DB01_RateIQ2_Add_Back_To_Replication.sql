/*----------------------------------------------------------------------------------
 INSTRUCTIONS 
------------------------------------------------------------------------------------
1. Check RateIQ2 replication is working (Replication Monitor tracer)
2. Pause replication (Stop Synchronizing in Replication Monitor)
3. Run "PART 1" of the script
4. Start Snapshot Agent in Replication Monitor and wait until it completed
5. Resume replication (Start Synchronizing in Replication Monitor)
6. Wait until snapshot for 3 articles is delivered and check tracer
7. Run "PART 2" of the script
----------------------------------------------------------------------------------*/

-- PART 1
USE [RateIQ2]
GO

DECLARE @subscriber sysname

SET @subscriber = 
	CASE @@SERVERNAME
		WHEN 'QA1-DB01' THEN 'QA1-DB02.qa.echogl.net'
		WHEN 'QA2-DB01' THEN 'QA2-DB02.qa.echogl.net'
		WHEN 'QA3-DB01' THEN 'QA3-DB02.qa.echogl.net'
		WHEN 'QA4-DB01' THEN 'QA4-DB02.qa.echogl.net'
		WHEN 'DB01VPRD' THEN 'DB02VPRD'
		WHEN 'DATATEAM4-DB01\DB01' THEN 'DATATEAM4-DB02.dev.echogl.net'
	END

SELECT @subscriber as [Subscriber Server]

IF @subscriber IS NULL
BEGIN
	PRINT 'ERROR: Wrong environment or SQL Server.';
	RETURN;
END;

-- publication
EXEC sp_changepublication @publication = 'PublicationRateIQ2', @property = 'allow_anonymous', @value = 'false'
EXEC sp_changepublication @publication = 'PublicationRateIQ2', @property = 'immediate_sync', @value = 'false'
-- Make sure the DDL changes are carried over
EXEC sp_changepublication @publication = 'PublicationRateIQ2', @property = 'replicate_ddl', @value = '1'

-- article
EXEC sp_addarticle @publication = N'PublicationRateIQ2', @article = N'RatingDetail', @source_owner = N'Production', @source_object = N'RatingDetail', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'truncate', @schema_option = 0x000000000803109F, @identityrangemanagementoption = N'manual', @destination_table = N'RatingDetail', @destination_owner = N'Production', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_ProductionRatingDetail]', @del_cmd = N'CALL [sp_MSdel_ProductionRatingDetail]', @upd_cmd = N'SCALL [sp_MSupd_ProductionRatingDetail]', @force_invalidate_snapshot = 1
EXEC sp_addsubscription @publication = N'PublicationRateIQ2', @subscriber = @subscriber, @destination_db = N'RateIQ2', @subscription_type = N'Push', @sync_type = N'automatic', @article = N'RatingDetail', @subscriber_type = 0, @reserved='Internal'

/*
-- PART 2
-- publication
EXEC sp_changepublication @publication = 'PublicationRateIQ2', @property = 'immediate_sync', @value = 'true'
EXEC sp_changepublication @publication = 'PublicationRateIQ2', @property = 'allow_anonymous', @value = 'true'
 --Make sure the DDL changes are not carried over
EXEC sp_changepublication @publication = 'PublicationRateIQ2', @property = 'replicate_ddl', @value = '0'
*/

GO