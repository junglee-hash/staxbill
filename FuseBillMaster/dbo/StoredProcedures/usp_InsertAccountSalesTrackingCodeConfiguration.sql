 
 
CREATE PROC [dbo].[usp_InsertAccountSalesTrackingCodeConfiguration]

	@Id bigint,
	@SalesTrackingCode1Label nvarchar(255),
	@SalesTrackingCode2Label nvarchar(255),
	@SalesTrackingCode3Label nvarchar(255),
	@SalesTrackingCode4Label nvarchar(255),
	@SalesTrackingCode5Label nvarchar(255),
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [AccountSalesTrackingCodeConfiguration] (
		[Id],
		[SalesTrackingCode1Label],
		[SalesTrackingCode2Label],
		[SalesTrackingCode3Label],
		[SalesTrackingCode4Label],
		[SalesTrackingCode5Label],
		[CreatedTimestamp],
		[ModifiedTimestamp]
	)
	VALUES (
		@Id,
		@SalesTrackingCode1Label,
		@SalesTrackingCode2Label,
		@SalesTrackingCode3Label,
		@SalesTrackingCode4Label,
		@SalesTrackingCode5Label,
		@CreatedTimestamp,
		@ModifiedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

