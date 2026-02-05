CREATE PROC [dbo].[usp_DeleteDraftPurchaseCharge]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [DraftPurchaseCharge]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

