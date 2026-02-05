CREATE   PROCEDURE [dbo].[usp_GetApiRules]
AS
BEGIN
	SELECT
		[Key]
		,IsWhitelisted
		,PerDayLimit AS PerDayLimit
		, PerMinuteLimit
		, AccountId
		FROM [dbo].[AccountApiKey]
		WHERE ApiKeyTypeId = 2
		AND ApiKeyStatusId = 1
END

GO

