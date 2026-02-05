 
 
CREATE PROC [dbo].[usp_InsertCoupon]

	@Name nvarchar(255),
	@Description nvarchar(500),
	@StatusId int,
	@ApplyToAllPlans bit,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@AccountId bigint
AS
SET NOCOUNT ON
	INSERT INTO [Coupon] (
		[Name],
		[Description],
		[StatusId],
		[ApplyToAllPlans],
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[AccountId]
	)
	VALUES (
		@Name,
		@Description,
		@StatusId,
		@ApplyToAllPlans,
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@AccountId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

