
CREATE PROCEDURE [dbo].[usp_GetFirstPageInterceptByUserId]
	@UserId bigint
	, @ControllerName varchar(100)
	, @ActionName varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT TOP 1 p.Id
	FROM Lookup.PageIntercept p
	LEFT JOIN UserPageIntercept pu ON pu.PageInterceptId = p.Id
		AND pu.UserId = @UserId
	WHERE 
		LOWER(p.SourceAction) = LOWER(@ActionName)
		AND LOWER(p.SourceController) = LOWER(@ControllerName)
		AND pu.Id IS NULL
END

GO

