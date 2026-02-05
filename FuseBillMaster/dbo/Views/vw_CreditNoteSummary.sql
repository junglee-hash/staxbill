
CREATE VIEW [dbo].[vw_CreditNoteSummary]
AS

SELECT
	c.Id as [FusebillId]
	,isnull(c.Reference,'') as [CustomerId]
	,Max(rc.Reference) as [Reference]
	,c.CurrencyId
	,i.AccountId
	,c.CompanyName
	,c.TitleId
	,c.FirstName
	,c.MiddleName
	,c.LastName
	,c.PrimaryEmail
	,c.Suffix
	,c.ParentId as CustomerParentId
	,i.InvoiceNumber
	,lc.IsoName AS Currency
	,i.PostedTimestamp as [InvoicePostedDate]
	,cg.Id
	,i.Id as [InvoiceId]
	,cg.number as [CreditNoteNumber]
	,Sum(t.Amount) as [Amount]
	,t.EffectiveTimestamp AS EffectiveTimestamp
	,cg.NetsuiteId as [NetsuiteId]
	,c.IsParent as CustomerIsParent
	,lcas.Name AS AccountingStatus
	,lcs.Name AS CustomerStatus
	,cngs.Name as CreditNoteStatus

FROM CreditNoteGroup cg
INNER JOIN CreditNote cn on cn.CreditNoteGroupId = cg.Id
INNER JOIN ReverseCharge rc on cn.Id = rc.CreditNoteId
INNER JOIN [Transaction] t on t.Id = rc.Id
INNER JOIN Invoice i on cg.InvoiceId = i.Id
INNER JOIN Customer c on c.Id = i.CustomerId
INNER JOIN Lookup.Currency lc ON lc.Id = c.CurrencyId
INNER JOIN Lookup.CustomerAccountStatus lcas ON c.AccountStatusId = lcas.Id
INNER JOIN Lookup.CustomerStatus lcs ON c.StatusId = lcs.Id
INNER JOIN Lookup.CreditNoteGroupStatus cngs ON cngs.Id = cg.CreditNoteGroupStatusId
Group by
c.Id
,c.Reference
,c.CurrencyId
,i.AccountId
,c.CompanyName
,c.TitleId
,c.FirstName
,c.MiddleName
,c.PrimaryEmail
,c.LastName
,c.Suffix
,c.ParentId 
,i.InvoiceNumber
,lc.IsoName 
,i.PostedTimestamp 
,cg.Id
,i.Id
,cg.number 
,t.EffectiveTimestamp 
,cg.NetsuiteId
,c.IsParent
,lcas.Name
,lcs.Name
,cngs.Name

GO

