CREATE FUNCTION [dbo].[fn_GetFormattedFrequency] 
	(@Interval AS varchar(255), 
	 @NumberOfIntervals AS int)
RETURNS varchar(255)
AS
BEGIN
	-- DECLARE VARIABLES
	DECLARE @NEWFREQUENCY AS varchar(255)
	
	set @NEWFREQUENCY = Concat('Every ', @NumberOfIntervals , ' ', 
	Case
		When @Interval = 'Monthly'
		Then 'Month'
		When @Interval = 'Yearly'
		then 'Year'
		else ''
	end, 
	CASE 
		WHEN @NumberOfIntervals > 1 
		THEN 's' 
		ELSE '' 
	end);

	-- Return the frequency string that has been nicely formatted
	RETURN @NEWFREQUENCY
END

GO

