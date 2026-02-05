CREATE PROC [dbo].[usp_UpdateCustomerStatusJournal]

	@Id bigint,
	@CustomerId bigint,
	@StatusId int,
	@CreatedTimestamp datetime,
	@IsActive bit
AS
SET NOCOUNT ON
	UPDATE [CustomerStatusJournal] SET 
		[CustomerId] = @CustomerId,
		[StatusId] = @StatusId,
		[CreatedTimestamp] = @CreatedTimestamp,
		[IsActive] = @IsActive
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

