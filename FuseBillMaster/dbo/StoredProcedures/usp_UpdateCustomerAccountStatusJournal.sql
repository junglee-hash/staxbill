
CREATE PROC [dbo].[usp_UpdateCustomerAccountStatusJournal]

	@Id bigint,
	@CustomerId bigint,
	@StatusId int,
	@CreatedTimestamp datetime,
	@IsActive bit,
	@EffectiveTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [CustomerAccountStatusJournal] SET 
		[CustomerId] = @CustomerId,
		[StatusId] = @StatusId,
		[CreatedTimestamp] = @CreatedTimestamp,
		[IsActive] = @IsActive,
		[EffectiveTimestamp] = @EffectiveTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

