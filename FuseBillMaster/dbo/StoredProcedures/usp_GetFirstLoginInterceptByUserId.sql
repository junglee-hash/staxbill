CREATE PROCEDURE [dbo].[usp_GetFirstLoginInterceptByUserId]
	@UserId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT TOP 1 l.Id
	FROM Lookup.LoginIntercept l
	LEFT JOIN UserLoginIntercept ul ON ul.LoginInterceptId = l.Id
		AND ul.UserId = @UserId
	INNER JOIN [User] u ON u.Id = @UserId
		AND u.CreatedTimestamp < COALESCE(l.UserCreatedBefore, GETUTCDATE())
	WHERE 
		ul.Id IS NULL
	ORDER BY l.SortOrder
END

GO

