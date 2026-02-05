 
 
CREATE PROC [dbo].[usp_InsertPlanProduct]

	@ProductId bigint,
	@PlanRevisionId bigint,
	@IsOptional bit,
	@IsIncludedByDefault bit,
	@IsFixed bit,
	@IsRecurring bit,
	@Quantity decimal,
	@MaxQuantity decimal,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@IsTrackingItems bit,
	@ResetTypeId int,
	@PlanProductUniqueId bigint,
	@StatusId int,
	@Name nvarchar(100),
	@Description nvarchar(1000),
	@Code nvarchar(1000),
	@ChargeAtSubscriptionActivation bit
AS
SET NOCOUNT ON
	INSERT INTO [PlanProduct] (
		[ProductId],
		[PlanRevisionId],
		[IsOptional],
		[IsIncludedByDefault],
		[IsFixed],
		[IsRecurring],
		[Quantity],
		[MaxQuantity],
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[IsTrackingItems],
		[ResetTypeId],
		[PlanProductUniqueId],
		[StatusId],
		[Name],
		[Description],
		[Code],
		[ChargeAtSubscriptionActivation]
	)
	VALUES (
		@ProductId,
		@PlanRevisionId,
		@IsOptional,
		@IsIncludedByDefault,
		@IsFixed,
		@IsRecurring,
		@Quantity,
		@MaxQuantity,
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@IsTrackingItems,
		@ResetTypeId,
		@PlanProductUniqueId,
		@StatusId,
		@Name,
		@Description,
		@Code,
		@ChargeAtSubscriptionActivation
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

