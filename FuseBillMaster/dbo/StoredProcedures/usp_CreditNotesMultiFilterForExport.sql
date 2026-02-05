
CREATE   PROCEDURE [dbo].[usp_CreditNotesMultiFilterForExport]
 --DECLARE  
 @AccountId bigint,   
 @creditNoteIds AS [dbo].[IdListSorted] ReadOnly   
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
  
Declare  
 @TimezoneId int  
  
select @TimezoneId = ad.TimezoneId   
from AccountPreference ad   
where ad.Id = @AccountId  
  
  
SELECT * INTO #CustomerData  
FROM dbo.BasicCustomerDataByAccount(@AccountId)  
  
 SELECT   
 cd.*  
 , cg.number as [Credit Note Number]
 , isnull(rc.Reference, '') as [Reference]
 , SUM(t.Amount) as [Amount]  
 , cur.IsoName as Currency  
 , i.InvoiceNumber as [Invoice Number]  
 , cg.NetsuiteId as [Credit Note NetSuiteId]  
 , dbo.fn_GetTimezoneTime(t.EffectiveTimestamp, ap.TimezoneId) as [Effective Timestamp]  
 , dbo.fn_GetTimezoneTime(i.[PostedTimestamp], ap.TimezoneId) as [Posted Timestamp]    
 , cngs.Name as [Credit Note Status]
 , IsNull(cg.[Trigger], '') as [Trigger]
 , case when cg.TriggeringUserId is null then '' else (COALESCE(u.FirstName,'') + ' ' + COALESCE(u.LastName,'')) end as [Triggering User]
    FROM @creditNoteIds as cnList  
  INNER JOIN dbo.creditnotegroup as  cg on  cnList.Id = cg.Id  
  INNER JOIN dbo.creditnote as  cn on  cnList.Id = cn.CreditNoteGroupId  
  INNER JOIN dbo.Invoice i on cg.invoiceid = i.id  
  INNER JOIN dbo.InvoiceCustomer as c ON i.id = c.InvoiceId  
  INNER JOIN dbo.InvoiceJournal AS ij ON i.Id = ij.InvoiceId AND ij.IsActive = 1   
  INNER JOIN ReverseCharge rc on cn.Id = rc.CreditNoteId  
  INNER JOIN [Transaction] t on t.Id = rc.Id  
  INNER JOIN Lookup.Currency cur ON cur.Id = c.CurrencyId  
  INNER JOIN AccountPreference ap ON ap.Id = i.AccountId  
  INNER JOIN #CustomerData cd on cd.[Fusebill ID] = i.CustomerId
  INNER JOIN Lookup.CreditNoteGroupStatus cngs ON cngs.Id = cg.CreditNoteGroupStatusId
  left join [User] u on u.Id = cg.TriggeringUserId
WHERE i.AccountId = @AccountId  
GROUP BY cg.Number, cd.[Customer First Name],cd .[Customer Company Name], cd.[Customer Primary Email], cd.[Customer Company Name], cd.[Customer ID],cd.[Customer Last Name], cd.[Customer Parent ID],cd.[Fusebill ID], cd.[Current Customer Status], cd.[Current Customer Accounting Status], cur.IsoName,  
i.InvoiceNumber, dbo.fn_GetTimezoneTime(t.EffectiveTimestamp, ap.TimezoneId), dbo.fn_GetTimezoneTime(i.[PostedTimestamp], ap.TimezoneId), cg.NetsuiteId, cnList.SortOrder, [Collection Likelihood],cngs.Name
,cg.[Trigger], cg.TriggeringUserId, u.FirstName, u.LastName, rc.Reference
order by cnList.SortOrder Asc  
  
drop table  #CustomerData  
  
END

GO

