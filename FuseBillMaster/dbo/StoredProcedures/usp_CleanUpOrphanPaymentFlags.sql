
CREATE PROCEDURE [dbo].[usp_CleanUpOrphanPaymentFlags]
AS
BEGIN

SELECT Id INTO #FlaggedCustomers
FROM customer c WHERE c.HasUnknownPayment = 1

UPDATE c
SET c.HasUnknownPayment = 1
FROM PaymentActivityJournal paj
INNER JOIN Customer c ON c.Id = paj.CustomerId
AND paj.PaymentActivityStatusId = 3 --unknown

UPDATE c
SET c.HasUnknownPayment = 0
FROM Customer c
INNER JOIN #FlaggedCustomers fc ON fc.Id = c.Id
LEFT JOIN PaymentActivityJournal paj ON fc.Id = paj.CustomerId
AND paj.PaymentActivityStatusId = 3 --unknown
WHERE paj.Id IS NULL

DROP TABLE #FlaggedCustomers

END

GO

