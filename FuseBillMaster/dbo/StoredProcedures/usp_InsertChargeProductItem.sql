 
 
CREATE PROC [dbo].[usp_InsertChargeProductItem]

	@ChargeId bigint,
	@ProductItemId bigint,
	@Name nvarchar(100),
	@Reference nvarchar(255),
	@Description varchar(255)
AS
SET NOCOUNT ON
	INSERT INTO [ChargeProductItem] (
		[ChargeId],
		[ProductItemId],
		[Name],
		[Reference],
		[Description]
	)
	VALUES (
		@ChargeId,
		@ProductItemId,
		@Name,
		@Reference,
		@Description
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

