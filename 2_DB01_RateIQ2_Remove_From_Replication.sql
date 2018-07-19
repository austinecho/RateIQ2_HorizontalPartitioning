/*
DataTeam
RateIQ2 Partitioning

Remove table from replication, will add back after schema changes

Run in DB01VPRD Equivilant 
*/
USE RateIQ2;
GO

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;  
GO 

exec sys.sp_dropsubscription @publication = 'PublicationRateIQ2',@article = 'Production.RatingDetail', @subscriber = N'all',@destination_db = N'all'
exec sp_droparticle @publication = 'PublicationRateIQ2', @article = 'Production.RatingDetail',@force_invalidate_snapshot = 0