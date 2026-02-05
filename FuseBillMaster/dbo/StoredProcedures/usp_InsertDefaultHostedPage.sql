 
 
CREATE PROC [dbo].[usp_InsertDefaultHostedPage]

	@HostedPageTypeId int,
	@Section nvarchar(50),
	@DefaultMarkup nvarchar(Max)
AS
SET NOCOUNT ON
	INSERT INTO [DefaultHostedPage] (
		[HostedPageTypeId],
		[Section],
		[DefaultMarkup]
	)
	VALUES (
		@HostedPageTypeId,
		@Section,
		@DefaultMarkup
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

