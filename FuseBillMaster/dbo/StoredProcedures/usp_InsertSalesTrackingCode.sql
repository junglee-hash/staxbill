 
 
CREATE PROC [dbo].[usp_InsertSalesTrackingCode]

	@AccountId bigint,
	@TypeId int,
	@Code nvarchar(255),
	@Name nvarchar(255),
	@Description nvarchar(1000),
	@Email nvarchar(255),
	@StatusId int,
	@Deletable bit,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [SalesTrackingCode] (
		[AccountId],
		[TypeId],
		[Code],
		[Name],
		[Description],
		[Email],
		[StatusId],
		[Deletable],
		[CreatedTimestamp],
		[ModifiedTimestamp]
	)
	VALUES (
		@AccountId,
		@TypeId,
		@Code,
		@Name,
		@Description,
		@Email,
		@StatusId,
		@Deletable,
		@CreatedTimestamp,
		@ModifiedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

