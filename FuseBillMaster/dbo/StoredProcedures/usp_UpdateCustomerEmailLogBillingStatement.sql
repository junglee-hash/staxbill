CREATE PROC [dbo].[usp_UpdateCustomerEmailLogBillingStatement]

	@Id bigint,
	@CustomerEmailLogId bigint,
	@BillingStatementId bigint
AS
SET NOCOUNT ON
	UPDATE [CustomerEmailLogBillingStatement] SET 
		[CustomerEmailLogId] = @CustomerEmailLogId,
		[BillingStatementId] = @BillingStatementId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

