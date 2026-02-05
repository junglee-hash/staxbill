 
 
CREATE PROC [dbo].[usp_InsertProductItem]

	@CreatedTimestamp datetime,
	@Reference nvarchar(255),
	@Name nvarchar(100),
	@Description varchar(255),
	@ModifiedTimestamp datetime,
	@ProductId bigint,
	@StatusId int
AS
SET NOCOUNT ON
	INSERT INTO [ProductItem] (
		[CreatedTimestamp],
		[Reference],
		[Name],
		[Description],
		[ModifiedTimestamp],
		[ProductId],
		[StatusId]
	)
	VALUES (
		@CreatedTimestamp,
		@Reference,
		@Name,
		@Description,
		@ModifiedTimestamp,
		@ProductId,
		@StatusId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

