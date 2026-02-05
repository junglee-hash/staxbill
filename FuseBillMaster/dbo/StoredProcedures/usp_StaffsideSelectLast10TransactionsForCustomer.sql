

CREATE Procedure [dbo].[usp_StaffsideSelectLast10TransactionsForCustomer]
	@CustomerId bigint
AS


set fmtonly off
set nocount on
		

select TOP 10 * 
from [Transaction]
Where CustomerId = @CustomerId
order by CreatedTimestamp desc

set nocount off

GO

