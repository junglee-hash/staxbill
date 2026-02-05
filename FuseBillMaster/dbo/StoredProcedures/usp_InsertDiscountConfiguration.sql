 
 
CREATE PROC [dbo].[usp_InsertDiscountConfiguration]

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
	INSERT INTO [DiscountConfiguration] (
		[AccountId],
		[RemainingUsagesUntilStart],
		[RemainingUsage],
		[Amount],
		[DiscountTypeId],
		[Name],
		[Description],
		[Code],
		[StatusId]
	)
	VALUES (
		@AccountId,
		@RemainingUsagesUntilStart,
		@RemainingUsage,
		@Amount,
		@DiscountTypeId,
		@Name,
		@Description,
		@Code,
		@StatusId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

