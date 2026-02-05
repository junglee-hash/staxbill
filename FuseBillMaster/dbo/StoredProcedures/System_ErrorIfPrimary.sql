
CREATE PROCEDURE [dbo].[System_ErrorIfPrimary]
AS

if exists (select *
from sys.dm_hadr_availability_replica_states s inner join sys.databases d on s.replica_id = d.replica_id
where role_desc  = 'Primary' 
) 
throw 50001, 'Abort operation, database is not the primary replica',1;

GO

