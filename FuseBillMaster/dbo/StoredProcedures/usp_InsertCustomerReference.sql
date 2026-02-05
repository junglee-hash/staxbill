 
 
CREATE PROC [dbo].[usp_InsertCustomerReference]

	@Id bigint,
	@Reference1 varchar(255),
	@Reference2 varchar(255),
	@Reference3 varchar(255),
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@ClassicId bigint,
	@SalesTrackingCode1Id bigint,
	@SalesTrackingCode2Id bigint,
	@SalesTrackingCode3Id bigint,
	@SalesTrackingCode4Id bigint,
	@SalesTrackingCode5Id bigint
AS
SET NOCOUNT ON
	INSERT INTO [CustomerReference] (
		[Id],
		[Reference1],
		[Reference2],
		[Reference3],
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[ClassicId],
		[SalesTrackingCode1Id],
		[SalesTrackingCode2Id],
		[SalesTrackingCode3Id],
		[SalesTrackingCode4Id],
		[SalesTrackingCode5Id]
	)
	VALUES (
		@Id,
		@Reference1,
		@Reference2,
		@Reference3,
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@ClassicId,
		@SalesTrackingCode1Id,
		@SalesTrackingCode2Id,
		@SalesTrackingCode3Id,
		@SalesTrackingCode4Id,
		@SalesTrackingCode5Id
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

