CREATE PROC [dbo].[usp_UpdateDefaultHostedPage]

	@Id bigint,
	@HostedPageTypeId int,
	@Section nvarchar(50),
	@DefaultMarkup nvarchar(Max)
AS
SET NOCOUNT ON
	UPDATE [DefaultHostedPage] SET 
		[HostedPageTypeId] = @HostedPageTypeId,
		[Section] = @Section,
		[DefaultMarkup] = @DefaultMarkup
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

