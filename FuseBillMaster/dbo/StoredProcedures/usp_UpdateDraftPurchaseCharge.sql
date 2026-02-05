CREATE PROC [dbo].[usp_UpdateDraftPurchaseCharge]

	@Id bigint,
	@PurchaseId bigint
AS
SET NOCOUNT ON
	UPDATE [DraftPurchaseCharge] SET 
		[PurchaseId] = @PurchaseId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

