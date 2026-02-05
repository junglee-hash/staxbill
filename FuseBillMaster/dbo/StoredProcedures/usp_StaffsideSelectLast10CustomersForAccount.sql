

CREATE Procedure [dbo].[usp_StaffsideSelectLast10CustomersForAccount]
	@AccountId bigint
AS


set fmtonly off
set nocount on
		

select TOP 10 * 
from Customer
Where AccountId = @AccountId
order by CreatedTimestamp desc

set nocount off

GO

