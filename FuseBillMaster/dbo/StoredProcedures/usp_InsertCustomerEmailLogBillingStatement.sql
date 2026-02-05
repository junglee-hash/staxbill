 
 
CREATE PROC [dbo].[usp_InsertCustomerEmailLogBillingStatement]

	@CustomerEmailLogId bigint,
	@BillingStatementId bigint
AS
SET NOCOUNT ON
	INSERT INTO [CustomerEmailLogBillingStatement] (
		[CustomerEmailLogId],
		[BillingStatementId]
	)
	VALUES (
		@CustomerEmailLogId,
		@BillingStatementId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

