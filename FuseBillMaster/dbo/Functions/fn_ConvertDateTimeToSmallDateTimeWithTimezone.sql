
create FUNCTION [dbo].[fn_ConvertDateTimeToSmallDateTimeWithTimezone]
(
	@DateToConvert datetime,
	@TimezoneId int
	
)
RETURNS smalldatetime
AS
BEGIN
	-- Declare the return variable here
	DECLARE 
	@ResultSmallDateTime smalldatetime,
	@TimezoneConvertedDate datetime

	select @TimezoneConvertedDate = dbo.fn_GetTimezoneTime(@DateToConvert,@TimezoneId )

	
	SELECT @ResultSmallDateTime = CASE 
				WHEN @TimezoneConvertedDate > '2078-06-06' OR @TimezoneConvertedDate < '1901-01-01' THEN null
				ELSE convert(smalldatetime,@TimezoneConvertedDate)
			   END 

	RETURN @ResultSmallDateTime

END

GO

