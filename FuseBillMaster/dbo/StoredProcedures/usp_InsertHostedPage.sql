 
 
CREATE PROC [dbo].[usp_InsertHostedPage]

	@AccountId bigint,
	@HostedPageTypeId int,
	@FriendlyName nvarchar(255),
	@HostedPageDomainId int,
	@Key nvarchar(255),
	@HostedPageStatusId int,
	@Header nvarchar(Max),
	@SubHeader nvarchar(Max),
	@Footer nvarchar(Max),
	@PreFooter nvarchar(Max),
	@CSS nvarchar(Max),
	@Menu nvarchar(Max),
	@GoogleAnalytics nvarchar(Max),
	@Version int
AS
SET NOCOUNT ON
	INSERT INTO [HostedPage] (
		[AccountId],
		[HostedPageTypeId],
		[FriendlyName],
		[HostedPageDomainId],
		[Key],
		[HostedPageStatusId],
		[Header],
		[SubHeader],
		[Footer],
		[PreFooter],
		[CSS],
		[Menu],
		[GoogleAnalytics],
		[Version]
	)
	VALUES (
		@AccountId,
		@HostedPageTypeId,
		@FriendlyName,
		@HostedPageDomainId,
		@Key,
		@HostedPageStatusId,
		@Header,
		@SubHeader,
		@Footer,
		@PreFooter,
		@CSS,
		@Menu,
		@GoogleAnalytics,
		@Version
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

