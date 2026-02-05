

CREATE   PROCEDURE [Reporting].[ManualNACHAFile]
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
WHERE Id = @AccountId;

WITH Credit_UnallocatedAmount AS
(
SELECT t.CustomerId
,SUM(cr.UnallocatedAmount) AS UnallocatedAmount
FROM Credit cr
INNER JOIN [Transaction] t ON cr.Id = t.Id
WHERE t.TransactionTypeId = 17
GROUP BY t.CustomerId)
,OpeningBalance_UnallocatedAmount AS
(
SELECT t.CustomerId
,SUM(ob.UnallocatedAmount) AS UnallocatedAmount
FROM OpeningBalance ob
INNER JOIN [Transaction] t ON ob.Id = t.Id
WHERE t.TransactionTypeId = 16
GROUP BY t.CustomerId)
,Payment_UnallocatedAmount AS
(
SELECT t.CustomerId
,SUM(p.UnallocatedAmount) AS UnallocatedAmount
FROM Payment p
INNER JOIN [Transaction] t ON p.Id = t.Id
WHERE t.TransactionTypeId = 3
GROUP BY t.CustomerId
)
SELECT
	dbo.fn_GetTimezoneTime(i.PostedTimestamp, @TimezoneId) as [Posted Timestamp]
	,cust.CompanyName as [Customer Name]
	,i.CustomerId as [Fusebill ID]
	,ISNULL(cust.Reference,'') as [Customer ID]
	,i.OutstandingBalance as [Amount to be Charged]
	,ISNULL(ca.LandingPage,'') as [Account Type]
	,ISNULL(ca.[Source],'')  as [Bank Routing #]
	,ISNULL(ca.Medium,'') as [Bank Account #]
	,i.InvoiceNumber as [Invoice #]
	,ISNULL(pau.UnallocatedAmount, 0) + ISNULL(cau.UnallocatedAmount, 0) + ISNULL(oau.UnallocatedAmount, 0) as [Available Funds]
	,cust.ArBalance as [Outstanding Balance]
FROM Invoice i 
Inner Join Customer cust on cust.Id = i.CustomerId
inner join [CustomerAcquisition] ca on ca.Id = cust.Id
inner join [CustomerReference] cr on cr.Id = cust.Id
inner join [SalesTrackingCode] st on st.Id = cr.[SalesTrackingCode5Id]
LEFT JOIN Payment_UnallocatedAmount pau on pau.CustomerId = i.CustomerId
LEFT JOIN OpeningBalance_UnallocatedAmount oau on oau.CustomerId = i.CustomerId
LEFT JOIN Credit_UnallocatedAmount cau on cau.CustomerId = i.CustomerId
WHERE i.AccountId = @AccountId
	AND i.PostedTimestamp >= @StartDate
	AND i.PostedTimestamp < @EndDate
	AND st.Code = 'YES'
	AND i.OutstandingBalance > 0
GROUP BY 
	i.PostedTimestamp
	,cust.CompanyName
	,i.CustomerId
	,cust.Reference
	,i.OutstandingBalance
	,ca.LandingPage
	,ca.Source
	,ca.Medium
	,i.InvoiceNumber
	,ISNULL(pau.UnallocatedAmount, 0)
	,ISNULL(cau.UnallocatedAmount, 0)
	,ISNULL(oau.UnallocatedAmount, 0)
	,cust.ArBalance
ORDER BY i.CustomerId

END

GO

