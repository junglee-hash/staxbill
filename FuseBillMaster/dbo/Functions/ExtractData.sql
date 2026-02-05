
CREATE FUNCTION [dbo].[ExtractData]
(
    @StringToSearch NVARCHAR(max),
	@StartString NVARCHAR(255),
	@EndString NVARCHAR(255)
)  
RETURNS @RtnValue TABLE
(
	ExtractedData NVARCHAR(MAX)
) 
AS  
BEGIN 

	DECLARE @ExtractedData NVARCHAR(MAX)
	DECLARE @Start int = CHARINDEX(@StartString, @StringToSearch)
	DECLARE @End int = CHARINDEX(@EndString, @StringToSearch, @Start)

	IF @Start > 0 AND @End > 0
	BEGIN
		SET @Start += LEN(@StartString)

		SET @ExtractedData = LTRIM(RTRIM(SUBSTRING(@StringToSearch, @Start, @End - @Start)))
	END

	INSERT INTO @RtnValue VALUES (@ExtractedData)

	RETURN
END

GO

