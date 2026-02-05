CREATE PROC [dbo].[usp_UpdateSelfServicePortalToken]

	@Id bigint,
	@Token uniqueidentifier,
	@CustomerId bigint,
	@CreatedTimestamp datetime,
	@IsConsumed bit,
	@TokenTypeID int
AS
SET NOCOUNT ON
	UPDATE [SelfServicePortalToken] SET 
		[Token] = @Token,
		[CustomerId] = @CustomerId,
		[CreatedTimestamp] = @CreatedTimestamp,
		[IsConsumed] = @IsConsumed,
		[TokenTypeID] = @TokenTypeID
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

