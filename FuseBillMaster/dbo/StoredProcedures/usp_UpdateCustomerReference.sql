CREATE PROC [dbo].[usp_UpdateCustomerReference]

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
	UPDATE [CustomerReference] SET 
		[Reference1] = @Reference1,
		[Reference2] = @Reference2,
		[Reference3] = @Reference3,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[ClassicId] = @ClassicId,
		[SalesTrackingCode1Id] = @SalesTrackingCode1Id,
		[SalesTrackingCode2Id] = @SalesTrackingCode2Id,
		[SalesTrackingCode3Id] = @SalesTrackingCode3Id,
		[SalesTrackingCode4Id] = @SalesTrackingCode4Id,
		[SalesTrackingCode5Id] = @SalesTrackingCode5Id
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

