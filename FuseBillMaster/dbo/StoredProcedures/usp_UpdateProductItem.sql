CREATE PROC [dbo].[usp_UpdateProductItem]

	@Id bigint,
	@CreatedTimestamp datetime,
	@Reference nvarchar(255),
	@Name nvarchar(100),
	@Description varchar(255),
	@ModifiedTimestamp datetime,
	@ProductId bigint,
	@StatusId int
AS
SET NOCOUNT ON
	UPDATE [ProductItem] SET 
		[CreatedTimestamp] = @CreatedTimestamp,
		[Reference] = @Reference,
		[Name] = @Name,
		[Description] = @Description,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[ProductId] = @ProductId,
		[StatusId] = @StatusId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

