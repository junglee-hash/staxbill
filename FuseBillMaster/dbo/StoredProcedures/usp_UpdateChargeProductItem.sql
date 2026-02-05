CREATE PROC [dbo].[usp_UpdateChargeProductItem]

	@Id bigint,
	@ChargeId bigint,
	@ProductItemId bigint,
	@Name nvarchar(100),
	@Reference nvarchar(255),
	@Description varchar(255)
AS
SET NOCOUNT ON
	UPDATE [ChargeProductItem] SET 
		[ChargeId] = @ChargeId,
		[ProductItemId] = @ProductItemId,
		[Name] = @Name,
		[Reference] = @Reference,
		[Description] = @Description
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

