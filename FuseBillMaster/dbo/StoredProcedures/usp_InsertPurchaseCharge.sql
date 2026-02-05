 
 
CREATE PROC [dbo].[usp_InsertPurchaseCharge]

	@Id bigint,
	@PurchaseId bigint,
	@CreatedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [PurchaseCharge] (
		[Id],
		[PurchaseId],
		[CreatedTimestamp]
	)
	VALUES (
		@Id,
		@PurchaseId,
		@CreatedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

