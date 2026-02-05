CREATE PROCEDURE [dbo].[usp_GetFullCreditNote]
--declare
	@creditNoteId bigint, -- This is actually the credit note group id
	@accountId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    declare @accountCreditNotes table
	(
		creditNoteGroupId bigint
	)

	-- starting point is credit note group
	insert into @accountCreditNotes
	select cng.id from CreditNoteGroup cng
	inner join Invoice i on cng.InvoiceId = i.Id
	where i.AccountId = @accountId
	and cng.id = @creditNoteId

Select cng.* from [dbo].[CreditNoteGroup] cng
inner join @accountCreditNotes acn on acn.creditNoteGroupId = cng.Id

SELECT cn.* FROM [dbo].[CreditNote] cn
inner join [dbo].[CreditNoteGroup] cng on cng.Id = cn.CreditNoteGroupId
inner join @accountCreditNotes acn on acn.creditNoteGroupId = cng.Id

SELECT i.* FROM [dbo].[Invoice] i
inner join [dbo].[CreditNoteGroup] cng on cng.InvoiceId = i.Id
inner join @accountCreditNotes acn on acn.creditNoteGroupId = cng.Id

SELECT ic.* FROM [dbo].[InvoiceCustomer] ic
INNER JOIN CreditNote cn ON cn.InvoiceId = ic.InvoiceId
inner join [dbo].[CreditNoteGroup] cng on cng.Id = cn.CreditNoteGroupId
inner join @accountCreditNotes acn on acn.creditNoteGroupId = cng.Id

SELECT c.*
	, t.*
	, c.EarningTimingTypeId as EarningTimingType
	, c.EarningTimingIntervalId as EarningTimingInterval
	, t.TransactionTypeId as TransactionType
FROM [dbo].[Charge] c
inner join ReverseCharge rc on rc.OriginalChargeId = c.Id
INNER JOIN [Transaction] t ON t.Id = c.Id
inner join [CreditNote] cn on cn.Id = rc.CreditNoteId
inner join [dbo].[CreditNoteGroup] cng on cng.Id = cn.CreditNoteGroupId
inner join @accountCreditNotes acn on acn.creditNoteGroupId = cng.Id

SELECT rc.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[ReverseCharge] rc
INNER JOIN [dbo].[Charge] c ON c.Id = rc.OriginalChargeId
INNER JOIN [Transaction] t ON t.Id = rc.Id
inner join [CreditNote] cn on cn.Id = rc.CreditNoteId
inner join [dbo].[CreditNoteGroup] cng on cng.Id = cn.CreditNoteGroupId
inner join @accountCreditNotes acn on acn.creditNoteGroupId = cng.Id

SELECT rd.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[ReverseDiscount] rd
INNER JOIN [Transaction] t ON t.Id = rd.Id
INNER JOIN [dbo].[Discount] d ON d.Id = rd.OriginalDiscountId
INNER JOIN [dbo].[Charge] c ON c.Id = d.ChargeId
inner join [CreditNote] cn on cn.Id = rd.CreditNoteId
inner join [dbo].[CreditNoteGroup] cng on cng.Id = cn.CreditNoteGroupId
inner join @accountCreditNotes acn on acn.creditNoteGroupId = cng.Id

SELECT rt.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[ReverseTax] rt
INNER JOIN [Transaction] t ON t.Id = rt.Id
INNER JOIN [dbo].[Tax] tax ON tax.Id = rt.OriginalTaxId
inner join [CreditNote] cn on cn.Id = rt.CreditNoteId
inner join [dbo].[CreditNoteGroup] cng on cng.Id = cn.CreditNoteGroupId
inner join @accountCreditNotes acn on acn.creditNoteGroupId = cng.Id

select cg.* from dbo.ChargeGroup cg
inner join Invoice i on i.Id = cg.InvoiceId
inner join [dbo].[CreditNoteGroup] cng on cng.InvoiceId = i.Id
inner join @accountCreditNotes acn on acn.creditNoteGroupId = cng.Id

SELECT c.*
	, c.TitleId as [Title]
	, c.StatusId as [Status]
	, c.AccountStatusId as [AccountStatus]
	, c.NetsuiteEntityTypeId as [NetsuiteEntityType]
	, c.SalesforceAccountTypeId as [SalesforceAccountType]
	, c.SalesforceSynchStatusId as [SalesforceSynchStatus]
FROM Customer c
INNER JOIN Invoice i ON c.Id = i.CustomerId
inner join [dbo].[CreditNoteGroup] cng on cng.InvoiceId = i.Id
inner join @accountCreditNotes acn on acn.creditNoteGroupId = cng.Id

SELECT d.*
	, t.*
	, d.DiscountTypeId as DiscountType
	, t.TransactionTypeId as TransactionType
FROM [dbo].[Discount] d
INNER JOIN [dbo].[Charge] c ON c.Id = d.ChargeId
INNER JOIN [Transaction] t ON t.Id = d.Id
inner join [dbo].[CreditNoteGroup] cng on cng.InvoiceId = c.InvoiceId
inner join @accountCreditNotes acn on acn.creditNoteGroupId = cng.Id

SELECT tax.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[Tax] tax
INNER JOIN CreditNote cn ON tax.InvoiceId = cn.InvoiceId
INNER JOIN [Transaction] t ON t.Id = tax.Id
inner join [dbo].[CreditNoteGroup] cng on cng.InvoiceId = tax.InvoiceId
inner join @accountCreditNotes acn on acn.creditNoteGroupId = cng.Id

-- Get all tax rules to avoid more queries based on transactions
SELECT * FROM TaxRule tr
WHERE tr.AccountId = @accountId

SELECT cis.*
    ,[TrackedItemDisplayFormatId] as TrackedItemDisplayFormat
	FROM CustomerInvoiceSetting cis
INNER JOIN Invoice i ON cis.Id = i.CustomerId
inner join [dbo].[CreditNoteGroup] cng on cng.InvoiceId = i.Id
inner join @accountCreditNotes acn on acn.creditNoteGroupId = cng.Id

SELECT ij.* FROM [dbo].[InvoiceJournal] ij
inner join [dbo].[CreditNoteGroup] cng on cng.InvoiceId = ij.InvoiceId
inner join @accountCreditNotes acn on acn.creditNoteGroupId = cng.Id
WHERE ij.IsActive = 1 

SELECT ia.[Id]
      ,[ModifiedTimestamp]
      ,[CreatedTimestamp]
      ,ia.[InvoiceId]
      ,[CompanyName]
      ,[Line1]
      ,[Line2]
      ,[CountryId]
      ,[StateId]
      ,[City]
      ,[PostalZip]
      ,[AddressTypeId] as [AddressType]
      ,[CountryName]
      ,[StateName]
      ,[UsedForAvalara] FROM [dbo].[InvoiceAddress] ia
inner join [dbo].[CreditNoteGroup] cng on cng.InvoiceId = ia.InvoiceId
inner join @accountCreditNotes acn on acn.creditNoteGroupId = cng.Id

SELECT rc.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[VoidReverseCharge] rc
INNER JOIN [Transaction] t ON t.Id = rc.Id
inner join [CreditNote] cn on cn.Id = rc.CreditNoteId
inner join [dbo].[CreditNoteGroup] cng on cng.Id = cn.CreditNoteGroupId
inner join @accountCreditNotes acn on acn.creditNoteGroupId = cng.Id

SELECT rd.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[VoidReverseDiscount] rd
INNER JOIN [Transaction] t ON t.Id = rd.Id
inner join [CreditNote] cn on cn.Id = rd.CreditNoteId
inner join [dbo].[CreditNoteGroup] cng on cng.Id = cn.CreditNoteGroupId
inner join @accountCreditNotes acn on acn.creditNoteGroupId = cng.Id

SELECT rt.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[VoidReverseTax] rt
INNER JOIN [Transaction] t ON t.Id = rt.Id
inner join [CreditNote] cn on cn.Id = rt.CreditNoteId
inner join [dbo].[CreditNoteGroup] cng on cng.Id = cn.CreditNoteGroupId
inner join @accountCreditNotes acn on acn.creditNoteGroupId = cng.Id

SELECT ij.* FROM [dbo].[InvoiceSignature] ij
INNER JOIN Invoice i ON ij.Id = i.InvoiceSignatureId
inner join [dbo].[CreditNoteGroup] cng on cng.InvoiceId = i.Id
inner join @accountCreditNotes acn on acn.creditNoteGroupId = cng.Id

END

GO

