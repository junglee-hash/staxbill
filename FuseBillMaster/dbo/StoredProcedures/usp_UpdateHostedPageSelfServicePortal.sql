CREATE PROC [dbo].[usp_UpdateHostedPageSelfServicePortal]

	@Id bigint,
	@UnauthenticatedHeader nvarchar(Max),
	@LoginLabel nvarchar(Max),
	@Home nvarchar(Max),
	@EnableStatements bit
AS
SET NOCOUNT ON
	UPDATE [HostedPageSelfServicePortal] SET 
		[UnauthenticatedHeader] = @UnauthenticatedHeader,
		[LoginLabel] = @LoginLabel,
		[Home] = @Home,
		[EnableStatements] = @EnableStatements
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

