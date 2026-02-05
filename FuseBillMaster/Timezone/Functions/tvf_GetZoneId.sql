

CREATE FUNCTION [Timezone].[tvf_GetZoneId]
(
	@TimezoneId BIGINT
) 
RETURNS TABLE WITH SCHEMABINDING AS 
RETURN
(
	SELECT TOP 1 COALESCE([ParentIANAZoneId],[IANAZoneId]) AS ZoneId
	FROM [Timezone].[ZoneTranslation] zt 
	WHERE zt.[Default] = 1
	AND zt.TimezoneId = @TimezoneId
	ORDER BY COALESCE([ParentIANAZoneId],[IANAZoneId]) DESC
)

GO

