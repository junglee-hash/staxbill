CREATE PROCEDURE [dbo].[usp_ErrorHandler] AS

DECLARE @errmsg NVARCHAR(2048),
 @severity TINYINT,
 @state TINYINT,
 @errno INT,
 @proc SYSNAME,
 @lineno INT

SELECT @errmsg = ERROR_MESSAGE(), @severity = ERROR_SEVERITY(),
 @state = ERROR_STATE(), @errno = ERROR_NUMBER(),
 @proc = ERROR_PROCEDURE(), @lineno = ERROR_LINE()

IF @errmsg NOT LIKE '***%'
BEGIN
 SELECT @errmsg = '*** ' + COALESCE(QUOTENAME(@proc), '<dynamic SQL>') + 
 ', Line ' + LTRIM(STR(@lineno)) + '. Errno ' + 
 LTRIM(STR(@errno)) + ': ' + @errmsg
END

RAISERROR('%s', @severity, @state, @errmsg)

GO

