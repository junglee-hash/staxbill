
CREATE PROCEDURE [Reporting].[Fusebill_NewFusebillUsers]
	@AccountId BIGINT = NULL
	,@StartDate DATETIME
	,@EndDate DATETIME
AS
BEGIN

SET TRANSACTION ISOLATION LEVEL SNAPSHOT
SET NOCOUNT ON

	
	--Return user and account details as well as last login date in UTC
	SELECT 
	au.[AccountId]
	,ISNULL(a.[CompanyName],'') AS [CompanyName]
	,c.[UserId]
	,c.[Username]
	,ISNULL(u.[Email],'') AS [Email]
	,ISNULL(u.[FirstName],'') AS [FirstName]
	,ISNULL(u.[LastName],'') AS [LastName]
	,CONVERT(VARCHAR,u.[CreatedTimestamp],23) AS CreatedDateUTC
	INTO #UserDetails
	FROM [User] u
	INNER JOIN [AccountUser] au ON au.[UserId] = u.[Id]
	INNER JOIN [Account] a ON a.[Id] = au.[AccountId]
	INNER JOIN [Credential] c ON c.[UserId] = u.[Id]
	WHERE[FusebillTest] = 0
	AND [Live] = 1
	AND [IsEnabled] = 1
	AND u.[CreatedTimestamp] >= @StartDate
	AND u.[CreatedTimestamp] < @EndDate

	--Stuff the AccountId and CompanyName for cases where a user is in multiple accounts
	SELECT DISTINCT
		[Username]
	--,STUFF(
		--	 (SELECT '; ' + CONVERT(VARCHAR(20),t2.[AccountId])
		--	  FROM #UserDetails t2
		--	  WHERE t1.[UserId] = t2.[UserId]
		--	  ORDER BY t2.[AccountId]
		--	  FOR XML PATH (''))
		--	  , 1, 2, '')  AS [AccountId]
		,STUFF(
			 (SELECT '; ' + CONVERT(VARCHAR(255),t2.[CompanyName]) + ' (' + CONVERT(VARCHAR(20),t2.[AccountId]) + ')'
			  FROM #UserDetails t2
			  WHERE t1.UserId = t2.[UserId]
			  ORDER BY t2.[CompanyName]
			  FOR XML PATH (''))
			  , 1, 2, '')  AS [CompanyName]
		,[Email]
		,[FirstName]
		,[LastName]
		,[CreatedDateUTC]
	FROM #UserDetails t1
	ORDER BY [Username]

DROP TABLE #UserDetails

SET NOCOUNT OFF

END

GO

