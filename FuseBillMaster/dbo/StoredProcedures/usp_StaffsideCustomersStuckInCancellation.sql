Create Procedure [dbo].[usp_StaffsideCustomersStuckInCancellation]
AS
Declare
	@RunDate datetime

set @RunDate = GETUTCDATE()

EXEC [dbo].[usp_CustomersEligibleForCancellation]
	 @RunTimeStamp = @RunDate

GO

