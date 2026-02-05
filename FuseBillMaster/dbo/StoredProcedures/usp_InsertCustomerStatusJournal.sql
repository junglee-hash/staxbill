 
 
CREATE PROC [dbo].[usp_InsertCustomerStatusJournal]

	@CustomerId bigint,
	@StatusId int,
	@CreatedTimestamp datetime,
	@IsActive bit
AS
SET NOCOUNT ON
	INSERT INTO [CustomerStatusJournal] (
		[CustomerId],
		[StatusId],
		[CreatedTimestamp],
		[IsActive]
	)
	VALUES (
		@CustomerId,
		@StatusId,
		@CreatedTimestamp,
		@IsActive
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

