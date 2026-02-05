
CREATE PROCEDURE [dbo].[usp_customerHasOpeningBalance]
	@customerId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @hasOpeningBalance bit = 0

    SELECT @hasOpeningBalance = COUNT(Id)
		FROM [Transaction]
		WHERE CustomerId = @customerId
			AND TransactionTypeId IN (16,19)

	IF @hasOpeningBalance = 0
	BEGIN
		SELECT @hasOpeningBalance = COUNT(Id)
		FROM DraftCharge
		WHERE CustomerId = @customerId
			AND TransactionTypeId = 19
	END

	SELECT @hasOpeningBalance
END

GO

