 
 
CREATE PROC [dbo].[usp_InsertDraftChargeProductItem]

	@DraftChargeId bigint,
	@ProductItemId bigint,
	@Name nvarchar(100),
	@Reference nvarchar(255),
	@Description varchar(255)
AS
SET NOCOUNT ON
	INSERT INTO [DraftChargeProductItem] (
		[DraftChargeId],
		[ProductItemId],
		[Name],
		[Reference],
		[Description]
	)
	VALUES (
		@DraftChargeId,
		@ProductItemId,
		@Name,
		@Reference,
		@Description
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

