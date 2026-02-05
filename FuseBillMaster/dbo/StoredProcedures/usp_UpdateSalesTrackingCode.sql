CREATE PROC [dbo].[usp_UpdateSalesTrackingCode]

	@Id bigint,
	@AccountId bigint,
	@TypeId int,
	@Code nvarchar(255),
	@Name nvarchar(255),
	@Description nvarchar(1000),
	@Email nvarchar(255),
	@StatusId int,
	@Deletable bit,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [SalesTrackingCode] SET 
		[AccountId] = @AccountId,
		[TypeId] = @TypeId,
		[Code] = @Code,
		[Name] = @Name,
		[Description] = @Description,
		[Email] = @Email,
		[StatusId] = @StatusId,
		[Deletable] = @Deletable,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

