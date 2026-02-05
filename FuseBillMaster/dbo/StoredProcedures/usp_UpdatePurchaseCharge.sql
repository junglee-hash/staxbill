CREATE PROC [dbo].[usp_UpdatePurchaseCharge]

	@Id bigint,
	@PurchaseId bigint,
	@CreatedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [PurchaseCharge] SET 
		[PurchaseId] = @PurchaseId,
		[CreatedTimestamp] = @CreatedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

