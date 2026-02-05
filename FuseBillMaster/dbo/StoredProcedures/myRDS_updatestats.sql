create procedure myRDS_updatestats
with execute as 'dbo'
as
exec sp_updatestats

GO

