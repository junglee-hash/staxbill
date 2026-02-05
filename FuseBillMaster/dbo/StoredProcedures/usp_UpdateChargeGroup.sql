CREATE PROC [dbo].[usp_UpdateChargeGroup]

	@Id bigint,
	@Name nvarchar(100),
	@Description nvarchar(1000),
	@Reference nvarchar(255),
	@InvoiceId bigint,
	@SubscriptionId bigint = null
AS
SET NOCOUNT ON
	UPDATE [ChargeGroup] SET 
		[Name] = @Name,
		[Description] = @Description,
		[Reference] = @Reference,
		[InvoiceId] = @InvoiceId,
		[SubscriptionId] = @SubscriptionId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

