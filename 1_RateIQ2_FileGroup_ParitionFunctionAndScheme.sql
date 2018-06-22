/*
DataTeam
RateIQ2 Partitioning

•	ADD New File Group
•	ADD 2 Partition Functions
•	ADD 2 Partition Schemes

Run in DB01VPRD Equivalent
*/
USE RateIQ2;
GO

IF ( SELECT @@SERVERNAME ) = 'DB01VPRD' BEGIN PRINT 'Running in Environment DB01VPRD...'; END;
ELSE IF ( SELECT @@SERVERNAME ) LIKE 'QA%' BEGIN PRINT 'Running in Environment QA-DB01...'; END;
ELSE IF ( SELECT @@SERVERNAME ) = 'DATATEAM4-DB01\DB01' BEGIN PRINT 'Running in Environment DATATEAM4-DB01\DB01...'; END;
ELSE BEGIN PRINT 'ERROR: Server name not found. Process stopped.'; RETURN; END;

--===================================================================================================
--ADD FILEGROUP
--===================================================================================================
PRINT '*** ADD FILE GROUP AND FILE***';

IF NOT EXISTS ( SELECT 1 FROM sys.filegroups WHERE name = 'RateIQ2_Archive' )
BEGIN 
	ALTER DATABASE RateIQ2 ADD FILEGROUP RateIQ2_Archive;

	IF ( SELECT @@SERVERNAME ) = 'DB01VPRD'
	BEGIN
		--PROD --Note: N:\Data\EchoTrak.MDF --PRIMARY
		ALTER DATABASE RateIQ2 ADD FILE ( NAME = 'RateIQ2_Archive', FILENAME = N'N:\Data\RateIQ2_Archive.NDF', SIZE = 6GB, MAXSIZE = UNLIMITED, FILEGROWTH = 1GB )
		TO FILEGROUP RateIQ2_Archive;
	END;
	ELSE IF ( SELECT @@SERVERNAME ) LIKE 'QA%'
	BEGIN
		--QA --Note: N:\Data\EchoTrak.MDF --PRIMARY
		ALTER DATABASE RateIQ2 ADD FILE ( NAME = 'RateIQ2_Archive', FILENAME = N'N:\Data\RateIQ2_Archive.NDF', SIZE = 6GB, MAXSIZE = UNLIMITED, FILEGROWTH = 1GB )
		TO FILEGROUP RateIQ2_Archive;
	END;
	ELSE IF ( SELECT @@SERVERNAME ) = 'DATATEAM4-DB01\DB01'
	BEGIN
		--DEV DT4 --Note: D:\Data\EchoTrak\EchoTrak_Primary.mdf --PRIMARY
		ALTER DATABASE RateIQ2 ADD FILE ( NAME = 'RateIQ2_Archive', FILENAME = N'D:\Data\RateIQ2_Archive.NDF', SIZE = 1GB, MAXSIZE = UNLIMITED, FILEGROWTH = 1GB )
		TO FILEGROUP RateIQ2_Archive;
		PRINT '- File [RateIQ2_Archive] added';
	END;

	PRINT '- Filegroup [RateIQ2_Archive] added';
END;
ELSE
BEGIN
    PRINT '!! WARNING: Filegroup with same name already exists !!';
END;
GO

--===================================================================================================
--ADD PARTITION FUNCTION
--===================================================================================================
PRINT '*** ADD PARTITION FUNCTION ***';

IF NOT EXISTS ( SELECT 1 FROM sys.partition_functions WHERE name = 'PF_RateIQ2_DATETIME_2Year' )
BEGIN
    CREATE PARTITION FUNCTION PF_RateIQ2_DATETIME_2Year ( DATETIME ) AS RANGE RIGHT FOR VALUES ( '2016-01-01 00:00:00.000' ); 

    PRINT '- Partition Function [PF_RateIQ2_DATETIME_2Year] added';
END;
ELSE
BEGIN
    PRINT '!! WARNING: Partition Function with same name already exists !!';
END;
GO

--===================================================================================================
--ADD PARTITION SCHEME
--===================================================================================================
PRINT '*** ADD PARTITION SCHEME ***';

IF NOT EXISTS ( SELECT 1 FROM sys.partition_schemes WHERE name = 'PS_RateIQ2_DATETIME_2Year' )
BEGIN
    CREATE PARTITION SCHEME PS_RateIQ2_DATETIME_2Year AS PARTITION PF_RateIQ2_DATETIME_2Year TO ( RateIQ2_Archive, [PRIMARY] );

	PRINT '- Partition Scheme [PS_RateIQ2_DATETIME_2Year] added';
END;
ELSE
BEGIN
    PRINT '!! WARNING: Partition Scheme with same name already exists !!';
END;
GO

--Verify: Check existance
/*
SELECT * FROM sys.partition_functions WHERE name = 'PF_RateIQ2_DATETIME_2Year';

SELECT * FROM sys.partition_schemes WHERE name = 'PS_RateIQ2_DATETIME_2Year';

SELECT * FROM sys.filegroups WHERE name = 'RateIQ2_Archive'

*/


