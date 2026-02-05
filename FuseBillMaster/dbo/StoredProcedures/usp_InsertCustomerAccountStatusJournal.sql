
CREATE PROC [dbo].[usp_InsertCustomerAccountStatusJournal]

	@CustomerId bigint,
	@StatusId int,
	@CreatedTimestamp datetime,
	@IsActive bit,
	@EffectiveTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [CustomerAccountStatusJournal] (
		[CustomerId],
		[StatusId],
		[CreatedTimestamp],
		[IsActive],
		[EffectiveTimestamp]
	)
	VALUES (
		@CustomerId,
		@StatusId,
		@CreatedTimestamp,
		@IsActive,
		@EffectiveTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

