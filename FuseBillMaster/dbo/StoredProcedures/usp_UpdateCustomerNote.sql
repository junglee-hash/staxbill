CREATE PROC [dbo].[usp_UpdateCustomerNote]

	@Id bigint,
	@CustomerId bigint,
	@UserId bigint,
	@Note varchar(2000),
	@CreatedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [CustomerNote] SET 
		[CustomerId] = @CustomerId,
		[UserId] = @UserId,
		[Note] = @Note,
		[CreatedTimestamp] = @CreatedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

