
CREATE PROC [dbo].[usp_UpdateAccountSalesTrackingCodeConfiguration]

	@Id bigint,
	@SalesTrackingCode1Label nvarchar(255),
	@SalesTrackingCode2Label nvarchar(255),
	@SalesTrackingCode3Label nvarchar(255),
	@SalesTrackingCode4Label nvarchar(255),
	@SalesTrackingCode5Label nvarchar(255),
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@SalesTrackingCode1DefaultId BIGINT,
	@SalesTrackingCode2DefaultId BIGINT,
	@SalesTrackingCode3DefaultId BIGINT,
	@SalesTrackingCode4DefaultId BIGINT,
	@SalesTrackingCode5DefaultId BIGINT

AS
SET NOCOUNT ON
	UPDATE [AccountSalesTrackingCodeConfiguration] SET 
		[SalesTrackingCode1Label] = @SalesTrackingCode1Label,
		[SalesTrackingCode2Label] = @SalesTrackingCode2Label,
		[SalesTrackingCode3Label] = @SalesTrackingCode3Label,
		[SalesTrackingCode4Label] = @SalesTrackingCode4Label,
		[SalesTrackingCode5Label] = @SalesTrackingCode5Label,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[SalesTrackingCode1DefaultId] = @SalesTrackingCode1DefaultId,
		[SalesTrackingCode2DefaultId] = @SalesTrackingCode2DefaultId,
		[SalesTrackingCode3DefaultId] = @SalesTrackingCode3DefaultId,
		[SalesTrackingCode4DefaultId] = @SalesTrackingCode4DefaultId,
		[SalesTrackingCode5DefaultId] = @SalesTrackingCode5DefaultId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

