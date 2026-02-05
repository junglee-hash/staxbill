
CREATE PROCEDURE [dbo].[usp_IsUniqueHostedPageKey]
	@Key nvarchar(255)
AS
BEGIN

	SELECT Count(*) from [dbo].[HostedPage] where [Key] = @Key Group by [Key]

END

GO

