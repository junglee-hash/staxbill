Create FUNCTION [dbo].[fn_GetCustomerCurrency]
(
	@CustomerId bigint
)
RETURNS  NVARCHAR(50)
AS
BEGIN
	DECLARE @Currency NVARCHAR(50) 

	SELECT @Currency = Lookup.Currency.IsoName FROM Lookup.Currency
	WHERE Lookup.Currency.Id = (SELECT top 1 CurrencyId FROM Customer WHERE Id = @CustomerId)

	RETURN @Currency
END


--(Interval, NumberOfIntervals * RemainingInterval, NextBillingDate)

GO

