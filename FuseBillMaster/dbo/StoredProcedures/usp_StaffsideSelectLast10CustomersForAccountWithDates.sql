
CREATE Procedure [dbo].[usp_StaffsideSelectLast10CustomersForAccountWithDates]
	@AccountId bigint
	,@StartDate datetime
	,@EndDate datetime
AS


set fmtonly off
set nocount on
		

select TOP 10 * 
from Customer
Where AccountId = @AccountId and CreatedTimeStamp > @StartDate
order by CreatedTimestamp desc

set nocount off

GO

