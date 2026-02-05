
Create PROCEDURE [Reporting].[FusebillPayments_CreditCardsUpdated]
--DECLARE
	@AccountId BIGINT 
	,@StartDate DATETIME 
	,@EndDate DATETIME 
AS
BEGIN

set nocount on
set transaction isolation level snapshot

DECLARE @TimezoneId BIGINT

SELECT @StartDate = dbo.fn_GetUtcTime(@StartDate, TimezoneId)
	,@EndDate = dbo.fn_GetUtcTime(@EndDate, TimezoneId)
	,@TimezoneId = TimezoneId
FROM AccountPreference
WHERE Id = @AccountId

SELECT
	c.Id as [Fusebill Id]
	,ISNULL(c.Reference,'') as [Customer Id]
	,ISNULL(c.FirstName,'') as [First Name]
	,ISNULL(c.LastName,'') as [Last Name]
	,ISNULL(c.CompanyName,'') as [Company Name]
	,cc.Id as [Credit Card Id]
	,pm.CreatedTimestamp as [Credit Card Updated] 
	,CASE WHEN pm.PaymentMethodStatusId = 1 THEN 'Yes' ELSE 'No' END AS [Most Recently Updated Card]
	,pm.FirstName + ' ' + pm.LastName as [Name On card]
	,cc.MaskedCardNumber as [Updated Card Number mask]
	,cc.ExpirationMonth as [Updated Expiry Month]
	,cc.ExpirationYear as [Updated Expiry Year]
	,ccOrig.MaskedCardNumber as [Original Masked Card Number]
	,ccOrig.ExpirationMonth as [Original Expiration Month]
	,ccOrig.ExpirationYear as [Original Expiration Year]
FROM PaymentMethod pm
INNER JOIN CreditCard cc ON cc.Id = pm.Id
INNER JOIN Customer c ON c.Id = pm.CustomerId
INNER JOIN PaymentMethod pmOrig ON pmOrig.Id = pm.OriginalPaymentMethodId
INNER JOIN CreditCard ccOrig ON pmOrig.Id = ccOrig.Id
WHERE c.AccountId = @AccountId
	AND pm.ModifiedTimestamp >= @StartDate
	AND pm.ModifiedTimestamp < @EndDate
	AND pm.OriginalPaymentMethodId is not null
ORDER BY c.Id

END

GO

