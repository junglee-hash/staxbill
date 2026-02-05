
-- =============================================
-- Description: Gets the nth occurrence of a given weekday in the month containing the specified date.
-- For @dayOfWeek, 1 = Sunday, 2 = Monday, 3 = Tuesday, 4 = Wednesday, 5 = Thursday, 6 = Friday, 7 = Saturday
-- =============================================
CREATE FUNCTION [dbo].[fn_GetDateFromDaylightSavingsOffset] 
(
@targetDate datetime,
@daylightSavingsOffset varchar(8)
)
RETURNS datetime
AS
BEGIN
	declare @dayOfWeek int
	declare @occurance int
	declare @month varchar(2)
	declare @hours varchar(2)
	declare @minutes varchar(2)
	declare @dateAsString varchar(20)

	DECLARE @date datetime
    DECLARE @beginMonth datetime
    DECLARE @offSet int
    DECLARE @firstWeekdayOfMonth datetime
    DECLARE @result datetime

/*If length is 7 pad with an extra '0' in front*/

if(len(@daylightSavingsOffset) = 7) set @daylightSavingsOffset = '0' + @daylightSavingsOffset 

/*parse out month - first two digits*/
set @month = substring(@daylightSavingsOffset, 1, 2)


/*occurance - third  digit*/
set @occurance = substring(@daylightSavingsOffset, 3, 1)

/*day of week - fourth digit*/
set @dayOfWeek = substring(@daylightSavingsOffset, 4, 1)

/*hour - 5-6 digit*/
set @hours = substring(@daylightSavingsOffset, 5, 2)

/*minutes - 7-8th digit*/
set @minutes = substring(@daylightSavingsOffset, 7, 2)


set @dateAsString = CAST(DATEPART(YEAR, @targetDate) as varchar(4)) + '-' + @month + '-' + '1 ' + @hours + ':' + @minutes

set @date = @dateAsString

/*start of ripped sproc*/

    SET @beginMonth = DATEADD(DAY, -DATEPART(DAY, @date) + 1, @date)
    SET @offSet = @dayOfWeek - DATEPART(dw, @beginMonth)

    IF (@offSet < 0)
    BEGIN
        SET @firstWeekdayOfMonth = DATEADD(d, 7 + @offSet, @beginMonth)
    END
    ELSE
    BEGIN
        SET @firstWeekdayOfMonth = DATEADD(d, @offSet, @beginMonth)
    END   
    

    SET @result = DATEADD(WEEK, @occurance - 1, @firstWeekdayOfMonth)

    IF (NOT(MONTH(@beginMonth) = MONTH(@result)))
    BEGIN
        SET @result = NULL
    END

    RETURN @result
END

GO

