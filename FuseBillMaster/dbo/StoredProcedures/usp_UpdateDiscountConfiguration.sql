CREATE PROC [dbo].[usp_UpdateDiscountConfiguration]

	@Id bigint,
	@AccountId bigint,
	@RemainingUsagesUntilStart int,
	@RemainingUsage int,
	@Amount decimal,
	@DiscountTypeId int,
	@Name nvarchar(255),
	@Description nvarchar(500),
	@Code nvarchar(255),
	@StatusId int
AS
SET NOCOUNT ON
	UPDATE [DiscountConfiguration] SET 
		[AccountId] = @AccountId,
		[RemainingUsagesUntilStart] = @RemainingUsagesUntilStart,
		[RemainingUsage] = @RemainingUsage,
		[Amount] = @Amount,
		[DiscountTypeId] = @DiscountTypeId,
		[Name] = @Name,
		[Description] = @Description,
		[Code] = @Code,
		[StatusId] = @StatusId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

