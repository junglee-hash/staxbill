 
 
CREATE PROC [dbo].[usp_InsertHostedPageSelfServicePortal]

	@Id bigint,
	@UnauthenticatedHeader nvarchar(Max),
	@LoginLabel nvarchar(Max),
	@Home nvarchar(Max),
	@EnableStatements bit
AS
SET NOCOUNT ON
	INSERT INTO [HostedPageSelfServicePortal] (
		[Id],
		[UnauthenticatedHeader],
		[LoginLabel],
		[Home],
		[EnableStatements]
	)
	VALUES (
		@Id,
		@UnauthenticatedHeader,
		@LoginLabel,
		@Home,
		@EnableStatements
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

