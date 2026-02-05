
CREATE PROCEDURE [Reporting].[TestAsOfNowProcedure]
	@AccountId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT TOP 10 * FROM Customer WHERE AccountId = @AccountId
	ORDER BY Id DESC
END

GO

