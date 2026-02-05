CREATE PROC [dbo].[usp_InsertChargeGroup]

	@Name nvarchar(100),
	@Description nvarchar(1000),
	@Reference nvarchar(255),
	@InvoiceId bigint,
	@SubscriptionId bigint = null
AS
SET NOCOUNT ON
	INSERT INTO [ChargeGroup] (
		[Name],
		[Description],
		[Reference],
		[InvoiceId],
		[SubscriptionId]
	)
	VALUES (
		@Name,
		@Description,
		@Reference,
		@InvoiceId,
		@SubscriptionId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

