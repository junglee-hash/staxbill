CREATE PROC [dbo].[usp_UpdatePurchasePriceRange]

	@Id bigint,
	@PurchaseId bigint,
	@Min decimal,
	@Max decimal,
	@Amount decimal
AS
SET NOCOUNT ON
	UPDATE [PurchasePriceRange] SET 
		[PurchaseId] = @PurchaseId,
		[Min] = @Min,
		[Max] = @Max,
		[Amount] = @Amount
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

