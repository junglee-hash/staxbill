
CREATE   PROC [dbo].[usp_UpdatePlan]

	@Id bigint,
	@AccountId bigint,
	@ModifiedTimestamp datetime,
	@CreatedTimestamp datetime,
	@Code nvarchar(255),
	@Name nvarchar(100),
	@Description nvarchar(1000),
	@StatusId int,
	@LongDescription nvarchar(Max),
	@Reference nvarchar(255),
	@AutoApplyChanges bit,
	@SalesforceCompatable bit
AS
SET NOCOUNT ON
	UPDATE [Plan] SET 
		[AccountId] = @AccountId,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[CreatedTimestamp] = @CreatedTimestamp,
		[Code] = @Code,
		[Name] = @Name,
		[Description] = @Description,
		[StatusId] = @StatusId,
		[LongDescription] = @LongDescription,
		[Reference] = @Reference,
		[AutoApplyChanges] = @AutoApplyChanges,
		[SalesforceCompatible] = @SalesforceCompatable
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

