
CREATE PROCEDURE [dbo].[usp_CustomerEligibleForAdditionalOffering]
	@customerId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @eligible bit = 0

    SELECT @eligible =  1 - COUNT(di.Id)
		FROM DraftInvoice di
		INNER JOIN Customer c on di.CustomerId = c.Id
		WHERE c.Id = @customerId
			AND di.DraftInvoiceStatusId IN (2,1) --ready and pending

	SELECT @eligible
END

GO

