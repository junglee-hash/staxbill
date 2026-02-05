
CREATE   PROC [dbo].[usp_InsertPlan]

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
	INSERT INTO [Plan] (
		[AccountId],
		[ModifiedTimestamp],
		[CreatedTimestamp],
		[Code],
		[Name],
		[Description],
		[StatusId],
		[LongDescription],
		[Reference],
		[AutoApplyChanges],
		[SalesforceCompatible]
	)
	SELECT
		@AccountId,
		@ModifiedTimestamp,
		@CreatedTimestamp,
		@Code,
		@Name,
		@Description,
		@StatusId,
		@LongDescription,
		@Reference,
		@AutoApplyChanges,
		@SalesforceCompatable
	
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

