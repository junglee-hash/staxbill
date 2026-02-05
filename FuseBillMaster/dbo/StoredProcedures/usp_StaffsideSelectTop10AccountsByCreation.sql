


CREATE Procedure [dbo].[usp_StaffsideSelectTop10AccountsByCreation]
AS


set fmtonly off
set nocount on
		

select TOP 10 * 
from Account
order by CreatedTimestamp desc

set nocount off

GO

