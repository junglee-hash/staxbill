 
 
CREATE PROC [dbo].[usp_InsertDraftPurchaseCharge]

	@Id bigint,
	@PurchaseId bigint
AS
SET NOCOUNT ON
	INSERT INTO [DraftPurchaseCharge] (
		[Id],
		[PurchaseId]
	)
	VALUES (
		@Id,
		@PurchaseId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

