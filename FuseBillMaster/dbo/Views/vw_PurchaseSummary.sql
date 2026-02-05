CREATE   VIEW [dbo].[vw_PurchaseSummary]
AS
SELECT  pur.Id,
        pur.[Name],
        prod.Code AS ProductCode,
        pur.PurchaseTimestamp AS FinalizationDate,
        pur.Amount as NetAmount,
        pur.CreatedTimestamp AS CreatedDate,
        pur.ModifiedTimestamp AS ModifiedTimestamp,
        pur.CancellationTimestamp AS CancellationDate,
        pur.[Description],
        c.Id AS CustomerId,
        c.AccountId,
        c.Reference,
        c.CurrencyId,
        c.FirstName,
        c.LastName,
        c.MiddleName,
        c.CompanyName,
		c.PrimaryEmail,
        pur.StatusId,
        i.InvoiceNumber,
		i.Id AS InvoiceId,
		ISNULL(ps.StatusId, 7)  AS InvoiceStatusId,
		CASE WHEN ps.StatusId = 4 THEN ps.LastJournalTimestamp ELSE NULL END AS DatePaid,
		pst.Name AS Status,
	   stc1.Id AS SalesTrackingCode1Id,
	   stc1.Code AS SalesTrackingCode1Code,
	   stc1.[Name] AS SalesTrackingCode1Name,
	   stc2.Id AS SalesTrackingCode2Id,
	   stc2.Code AS SalesTrackingCode2Code,
	   stc2.[Name] AS SalesTrackingCode2Name,
	   stc3.Id AS SalesTrackingCode3Id,
	   stc3.Code AS SalesTrackingCode3Code,
	   stc3.[Name] AS SalesTrackingCode3Name,
	   stc4.Id AS SalesTrackingCode4Id,
	   stc4.Code AS SalesTrackingCode4Code,
	   stc4.[Name] AS SalesTrackingCode4Name,
	   stc5.Id AS SalesTrackingCode5Id,
	   stc5.Code AS SalesTrackingCode5Code,
	   stc5.[Name] AS SalesTrackingCode5Name,
	   c.ParentId AS CustomerParentId,
       c.IsParent as CustomerIsParent,
	   Lookup.CustomerAccountStatus.Name AS AccountingStatus,
	   Lookup.CustomerStatus.Name AS CustomerStatus
FROM    dbo.Purchase pur
INNER JOIN 
        Lookup.PurchaseStatus pst on pst.Id = pur.StatusId
INNER JOIN
        dbo.Product prod ON pur.ProductId = prod.Id
INNER JOIN
        dbo.Customer c ON pur.CustomerId = c.Id AND c.AccountId = prod.AccountId
LEFT JOIN
        dbo.PurchaseCharge pc ON pc.PurchaseId = pur.Id
LEFT JOIN
        dbo.Charge ch on pc.Id = ch.Id
LEFT JOIN
        dbo.Invoice i on i.Id = ch.InvoiceId
LEFT JOIN dbo.PaymentSchedule ps ON ps.InvoiceId = i.Id
INNER JOIN dbo.CustomerReference AS cr ON cr.Id = c.Id 
   LEFT JOIN SalesTrackingCode stc1 ON cr.SalesTrackingCode1Id = stc1.Id
   LEFT JOIN SalesTrackingCode stc2 ON cr.SalesTrackingCode2Id = stc2.Id
   LEFT JOIN SalesTrackingCode stc3 ON cr.SalesTrackingCode3Id = stc3.Id
   LEFT JOIN SalesTrackingCode stc4 ON cr.SalesTrackingCode4Id = stc4.Id
   LEFT JOIN SalesTrackingCode stc5 ON cr.SalesTrackingCode5Id = stc5.Id
INNER JOIN Lookup.CustomerAccountStatus ON c.AccountStatusId = Lookup.CustomerAccountStatus.Id
INNER JOIN Lookup.CustomerStatus ON c.StatusId = Lookup.CustomerStatus.Id
WHERE pur.IsDeleted = 0

GO

