CREATE PROC [dbo].[usp_UpdateCoupon]

	@Id bigint,
	@Name nvarchar(255),
	@Description nvarchar(500),
	@StatusId int,
	@ApplyToAllPlans bit,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@AccountId bigint
AS
SET NOCOUNT ON
	UPDATE [Coupon] SET 
		[Name] = @Name,
		[Description] = @Description,
		[StatusId] = @StatusId,
		[ApplyToAllPlans] = @ApplyToAllPlans,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[AccountId] = @AccountId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

