CREATE PROC [dbo].[usp_UpdateCustomerEmailControl]

	@Id bigint,
	@CustomerId bigint,
	@EmailKey varchar(50),
	@CreatedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [CustomerEmailControl] SET 
		[CustomerId] = @CustomerId,
		[EmailKey] = @EmailKey,
		[CreatedTimestamp] = @CreatedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

