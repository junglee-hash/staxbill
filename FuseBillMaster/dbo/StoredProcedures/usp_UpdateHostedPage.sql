CREATE PROC [dbo].[usp_UpdateHostedPage]

	@Id bigint,
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
	UPDATE [HostedPage] SET 
		[AccountId] = @AccountId,
		[HostedPageTypeId] = @HostedPageTypeId,
		[FriendlyName] = @FriendlyName,
		[HostedPageDomainId] = @HostedPageDomainId,
		[Key] = @Key,
		[HostedPageStatusId] = @HostedPageStatusId,
		[Header] = @Header,
		[SubHeader] = @SubHeader,
		[Footer] = @Footer,
		[PreFooter] = @PreFooter,
		[CSS] = @CSS,
		[Menu] = @Menu,
		[GoogleAnalytics] = @GoogleAnalytics,
		[Version] = @Version
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

