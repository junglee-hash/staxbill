CREATE PROC [dbo].[usp_UpdateDraftChargeProductItem]

	@Id bigint,
	@DraftChargeId bigint,
	@ProductItemId bigint,
	@Name nvarchar(100),
	@Reference nvarchar(255),
	@Description varchar(255)
AS
SET NOCOUNT ON
	UPDATE [DraftChargeProductItem] SET 
		[DraftChargeId] = @DraftChargeId,
		[ProductItemId] = @ProductItemId,
		[Name] = @Name,
		[Reference] = @Reference,
		[Description] = @Description
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

