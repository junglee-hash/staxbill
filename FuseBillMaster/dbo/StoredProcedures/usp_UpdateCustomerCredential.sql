CREATE PROC [dbo].[usp_UpdateCustomerCredential]

	@Id bigint,
	@Username nvarchar(50),
	@Password varchar(255),
	@Salt varchar(255),
	@AccountId bigint,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [CustomerCredential] SET 
		[Username] = @Username,
		[Password] = @Password,
		[Salt] = @Salt,
		[AccountId] = @AccountId,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

