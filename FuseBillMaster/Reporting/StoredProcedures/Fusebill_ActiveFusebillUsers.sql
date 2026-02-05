
CREATE PROCEDURE [Reporting].[Fusebill_ActiveFusebillUsers]
	@AccountId BIGINT = NULL
AS
BEGIN

SET TRANSACTION ISOLATION LEVEL SNAPSHOT
SET NOCOUNT ON

	--Filter and rank AuditTrail records for Admin Logins in the last 12 months
	;WITH CTE_AuditTrailRanked AS (
		SELECT 
		[AccountId]
		,[EntityValue]
		,[CreatedTimestamp]
		,ROW_NUMBER() OVER( PARTITION BY [AccountId],[EntityValue] ORDER BY [CreatedTimestamp] DESC) AS [RowNumber]
		FROM [AuditTrail]
		WHERE [ActionId] = 5
		AND [SourceId] = 1
		AND [CreatedTimestamp] > DATEADD(MONTH,-12,GETUTCDATE())
		)

	--Return user and account details as well as last login date in UTC
	SELECT 
	atr.[AccountId]
	,ISNULL(a.[CompanyName],'(Not Specified)') AS [CompanyName]
	,c.[UserId]
	,c.[Username]
	,ISNULL(u.[Email],'') AS [Email]
	,ISNULL(u.[FirstName],'') AS [FirstName]
	,ISNULL(u.[LastName],'') AS [LastName]
	,CONVERT(VARCHAR,atr.[CreatedTimestamp],23) AS [LastLoginUTC]
	INTO #AuditDetails
	FROM CTE_AuditTrailRanked atr
	INNER JOIN [Account] a ON a.[Id] = atr.[AccountId]
	INNER JOIN [Credential] c ON c.[Username] = atr.[EntityValue]
	INNER JOIN [User] u ON u.Id = c.[UserId]
	INNER JOIN [AccountUser] au 
		ON au.[UserId] = u.[Id]
		AND atr.[AccountId] = au.[AccountId]
	WHERE [RowNumber] = 1
	AND [FusebillTest] = 0
	AND [Live] = 1
	AND [IsEnabled] = 1
		

	--Stuff the AccountId and CompanyName for cases where a user is in multiple accounts
	SELECT
		[Username]
		--,STUFF(
		--	 (SELECT '; ' + CONVERT(VARCHAR(20),t2.[AccountId])
		--	  FROM #AuditDetails t2
		--	  WHERE t1.[UserId] = t2.[UserId]
		--	  ORDER BY t2.[AccountId]
		--	  FOR XML PATH (''))
		--	  , 1, 2, '')  AS [AccountId]
		,STUFF(
			 (SELECT '; ' + CONVERT(VARCHAR(255),t2.[CompanyName]) + ' (' + CONVERT(VARCHAR(20),t2.[AccountId]) + ')'
			  FROM #AuditDetails t2
			  WHERE t1.UserId = t2.[UserId]
			  ORDER BY t2.[CompanyName]
			  FOR XML PATH (''))
			  , 1, 2, '')  AS [CompanyName]
		,[Email]
		,[FirstName]
		,[LastName]
		,MAX([LastLoginUTC]) AS [LastLoginUTC]
	FROM #AuditDetails t1
	GROUP BY 
		[Username]
		,[UserId]
		,[Email]
		,[FirstName]
		,[LastName]
	ORDER BY [Username]

DROP TABLE #AuditDetails

SET NOCOUNT OFF

END

GO

