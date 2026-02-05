CREATE PROC [dbo].[usp_UpdatePlanProduct]

	@Id bigint,
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
	UPDATE [PlanProduct] SET 
		[ProductId] = @ProductId,
		[PlanRevisionId] = @PlanRevisionId,
		[IsOptional] = @IsOptional,
		[IsIncludedByDefault] = @IsIncludedByDefault,
		[IsFixed] = @IsFixed,
		[IsRecurring] = @IsRecurring,
		[Quantity] = @Quantity,
		[MaxQuantity] = @MaxQuantity,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[IsTrackingItems] = @IsTrackingItems,
		[ResetTypeId] = @ResetTypeId,
		[PlanProductUniqueId] = @PlanProductUniqueId,
		[StatusId] = @StatusId,
		[Name] = @Name,
		[Description] = @Description,
		[Code] = @Code,
		[ChargeAtSubscriptionActivation] = @ChargeAtSubscriptionActivation
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

