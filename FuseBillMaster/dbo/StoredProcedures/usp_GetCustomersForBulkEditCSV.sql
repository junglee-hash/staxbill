
CREATE   PROCEDURE [dbo].[usp_GetCustomersForBulkEditCSV]

--declare  
 @AccountId bigint = 19  
 ,@Customers  nvarchar(max) = ''  
 ,@IncludeIdentification bit = 1  
 ,@IncludeAddresses bit = 1  
 ,@IncludeTracking bit = 1  
 ,@IncludeEmail bit = 0
 ,@IncludeHierarchyColumns bit = 0
 ,@IncludePaymentOptions bit = 0
AS  
BEGIN  
 SET NOCOUNT ON;  
  
declare @TimezoneId int  
  
select @TimezoneId = TimezoneId from AccountPreference where Id = @AccountId   
  
DECLARE @PivotCols_EmailTypes NVARCHAR(MAX)  
DECLARE @PivotCols_EmailDescriptor NVARCHAR(MAX)  
  
SELECT @PivotCols_EmailTypes =   
   STUFF((SELECT ',[Email.' + REPLACE([Name], ' ', '') + ']'  
      FROM Lookup.EmailTemplateType WHERE SortOrder IS NOT NULL  
    FOR XML PATH('')),1,1,'')  
  
SELECT @PivotCols_EmailDescriptor =   
   STUFF((SELECT ',''Email.' + REPLACE([Name], ' ', '') + ' (On/Off/Default)'' as [Email.' + REPLACE([Name], ' ', '') + ']'  
      FROM Lookup.EmailTemplateType WHERE SortOrder IS NOT NULL  
    FOR XML PATH('')),1,1,'')  
  
DECLARE @sql nvarchar(max)  
  
SELECT @SQL = N'  
declare @customerIds table  
(  
 customerId bigint  
)  
  
insert into @customerIds  
select Data from dbo.Split(@Customers,''|'')  
  
select  
''Fusebill Id (DO NOT CHANGE)'' as [FusebillId]'+  
CASE WHEN @IncludeIdentification = 1 THEN   
' ,''Reference (255 char)'' as Reference  
 ,''First Name (50 char)'' as FirstName  
 ,''Last Name (50 char)'' as LastName  
 ,''Company Name (255 char)'' as CompanyName  
 ,''Primary Email (comma or semicolon separated, 255 char)'' as PrimaryEmail  
 ,''Primary Phone (50 char)'' as PrimaryPhone ' ELSE '' END +
CASE WHEN @IncludePaymentOptions = 1 THEN  
',''Net Terms'' as [NetTerms]
 ,''Target Net Terms'' as [TargetNetTerms]
 ,''Auto Post'' as [AutoPost]
 ,''Target Auto Post'' as [TargetAutoPost]
 ,''Auto Collect'' as [AutoCollect]
 ,''Target Auto Collect'' as [TargetAutoCollect]
 ,''Auto Collect Options'' as [AutoCollectOptions]
 ,''Target Auto Collect Options'' as [TargetAutoCollectOptions]
 ,''Dunning'' as [Dunning]
 ,''Target Dunning'' as [TargetDunning]
 ,''Post Ready on renewal'' as [PostReadyOnRenewal] 
 ,''Target Post Ready on renewal'' as [TargetPostReadyOnRenewal] ' ELSE '' END +
CASE WHEN @IncludeAddresses = 1 THEN   
', ''Billing Line 1 (60 char)'' as [Billing.Line1]  
, ''Billing Line 2 (60 char)'' as [Billing.Line2]  
, ''Billing City (50 char)'' as [Billing.City]  
, ''Billing County (150 char)'' as [Billing.County]  
, ''Billing County (250 char)'' as [Billing.State]  
, ''Billing Country (250 char)'' as [Billing.Country]  
, ''Billing Postal/Zip (255 char)'' as [Billing.PostalZip]  
, ''Shipping Line 1 (60 char)'' as [Shipping.Line1]  
, ''Shipping Line 2 (60 char)'' as [Shipping.Line2]  
, ''Shipping City (50 char)'' as [Shipping.City]  
, ''Shipping County (150 char)'' as [Shipping.County]  
, ''Shipping State (250 char)'' as [Shipping.State]  
, ''Shipping Country (250 char)'' as [Shipping.Country]  
, ''Shipping Postal/Zip (255 char)'' as [Shipping.PostalZip] ' ELSE '' END +  
CASE WHEN @IncludeTracking = 1 THEN   
', ''Reference 1 (255 char)'' as [CustomerReference.Reference1]  
, ''Reference 2 (255 char)'' as [CustomerReference.Reference2]  
, ''Reference 3 (255 char)'' as [CustomerReference.Reference3]  
, ''Sales Tracking Code 1 (255 char)'' as [SalesTrackingCode1]  
, ''Sales Tracking Code 2 (255 char)'' as [SalesTrackingCode2]  
, ''Sales Tracking Code 3 (255 char)'' as [SalesTrackingCode3]  
, ''Sales Tracking Code 4 (255 char)'' as [SalesTrackingCode4]  
, ''Sales Tracking Code 5 (255 char)'' as [SalesTrackingCode5]  
, ''Ad Content (255 char)'' as [CustomerAcquisition.AdContent]  
, ''Campaign (255 char)'' as [CustomerAcquisition.Campaign]  
, ''Keyword (255 char)''  as [CustomerAcquisition.Keyword]  
, ''Landing Page (255 char)'' as [CustomerAcquisition.LandingPage]  
, ''Medium (255 char)'' as [CustomerAcquisition.Medium]  
, ''Source (255 char)'' as [CustomerAcquisition.Source] ' ELSE '' END +  
CASE WHEN @IncludeEmail = 1 THEN  
-- Some how pivot email type and include descriptor text  
', ' + @PivotCols_EmailDescriptor   
ELSE '' END +  
CASE WHEN @IncludeHierarchyColumns = 1 THEN   
', ''Fusebill ID of the target parent of this customer. Leave blank to avoid changes, use ''''clear'''' to remove parent.'' as [ParentFusebillId]  
 , ''Customer ID of the target parent customer. This must be unique on an active customer in Fusebill and a valid parent. Leave blank to avoid changes.'' as [ParentReferenceId] ' ELSE '' END +  
'   
union all   
SELECT   
CAST (c.Id as varchar(25)) as [FusebillId]'  
+  
CASE WHEN @IncludeIdentification = 1 THEN   
' , c.Reference  
, c.FirstName  
, c.LastName  
, c.CompanyName  
, c.PrimaryEmail  
, c.PrimaryPhone ' ELSE '' END + 
CASE WHEN @IncludePaymentOptions = 1 THEN
', t.Name as [NetTerms]
, null as [TargetNetNerms]
, CAST(CASE WHEN cbs.AutoPostDraftInvoice = 0 THEN ''0'' WHEN cbs.AutoPostDraftInvoice IS NULL THEN ''Default'' ELSE ''1'' END as varchar) as [AutoPost]
, null as [TargetAutoPost]
, CAST(CASE WHEN cbs.AutoCollect = 0 THEN ''0'' WHEN cbs.AutoCollect IS NULL THEN ''Default'' ELSE ''1'' END as varchar) as [AutoCollect]
, null as [TargetAutoCollect]
, acst.Name as [AutoCollectOptions]
, null as [TargetAutoCollectOptions]
, CAST(CASE WHEN cbs.DunningExempt = 0 THEN ''0'' WHEN cbs.DunningExempt IS NULL THEN ''Default'' ELSE ''1'' END as varchar) as [Dunning]
, null as [TargetDunning]
, CAST(CASE WHEN cbs.PostReadyChargesOnRenew = 0 THEN ''0'' WHEN cbs.PostReadyChargesOnRenew IS NULL THEN ''Default'' ELSE ''1'' END as varchar) as [PostReadyOnRenewal]
, null as [TargetPostReadyOnRenewal]' ELSE '' END +
CASE WHEN @IncludeAddresses = 1 THEN   
', ba.Line1 as [Billing.Line1]  
, ba.Line2 as [Billing.Line2]  
, ba.City as [Billing.City]  
, ba.County as [Billing.County]  
, ba.[State] as [Billing.State]  
, ba.Country as [Billing.Country]  
, ba.PostalZip as [Billing.PostalZip]  
, sa.Line1 as [Shipping.Line1]  
, sa.Line2 as [Shipping.Line2]  
, sa.City as [Shipping.City]  
, sa.County as [Shipping.County]  
, sa.[State] as [Shipping.State]  
, sa.Country as [Shipping.Country]  
, sa.PostalZip as [Shipping.PostalZip] ' ELSE '' END +  
CASE WHEN @IncludeTracking = 1 THEN   
', cr.Reference1 as [CustomerReference.Reference1]  
, cr.Reference2 as [CustomerReference.Reference2]  
, cr.Reference3 as [CustomerReference.Reference3]  
, stc1.Code as [SalesTrackingCode1]  
, stc2.Code as [SalesTrackingCode2]  
, stc3.Code as [SalesTrackingCode3]  
, stc4.Code as [SalesTrackingCode4]  
, stc5.Code as [SalesTrackingCode5]  
, ca.AdContent as [CustomerAcquisition.AdContent]  
, ca.Campaign as [CustomerAcquisition.Campaign]  
, ca.Keyword as [CustomerAcquisition.Keyword]  
, ca.LandingPage as [CustomerAcquisition.LandingPage]  
,ca.Medium as [CustomerAcquisition.Medium]  
,ca.Source as [CustomerAcquisition.Source] ' ELSE '' END +  
CASE WHEN @IncludeEmail = 1 THEN  
-- Some how pivot email type and customer value  
', ' + @PivotCols_EmailTypes + '  
'  
ELSE '' END +  
CASE WHEN @IncludeHierarchyColumns = 1 THEN   
', cast(c.ParentId as varchar) AS [ParentFusebillID]  
, parentCustomer.Reference AS [ParentReferenceID]  ' ELSE '' END +  

'FROM customer c  
INNER JOIN @customerIds ci on ci.customerId = c.id ';  

--print @SQL
  
SET @sql = @sql +  
  
CASE WHEN @IncludeAddresses = 1 THEN   
'LEFT JOIN [Address] ba on ba.CustomerAddressPreferenceId = c.Id and ba.AddressTypeId = 1  
LEFT JOIN [Address] sa on sa.CustomerAddressPreferenceId = c.Id and sa.AddressTypeId = 2 ' ELSE '' END +  
CASE WHEN @IncludePaymentOptions = 1 THEN   
'LEFT JOIN CustomerBillingSetting cbs on cbs.Id = c.Id 
LEFT JOIN Lookup.Term t on t.Id = cbs.TermId 
LEFT JOIN Lookup.AutoCollectSettingType acst on acst.Id = cbs.AutoCollectSettingTypeId ' ELSE '' END +  
CASE WHEN @IncludeTracking = 1 THEN   
'LEFT JOIN CustomerAcquisition ca on ca.Id = c.Id  
LEFT JOIN CustomerReference cr on cr.Id = c.Id  
left join SalesTrackingCode stc1 on cr.SalesTrackingCode1Id = stc1.Id  
left join SalesTrackingCode stc2 on cr.SalesTrackingCode2Id = stc2.Id  
left join SalesTrackingCode stc3 on cr.SalesTrackingCode3Id = stc3.Id  
left join SalesTrackingCode stc4 on cr.SalesTrackingCode4Id = stc4.Id  
left join SalesTrackingCode stc5 on cr.SalesTrackingCode5Id = stc5.Id ' ELSE '' END +  
CASE WHEN @IncludeEmail = 1 THEN  
'INNER JOIN (  
 SELECT CustomerId, ' + @PivotCols_EmailTypes +   
 'FROM (  
  SELECT cep.CustomerId, CASE WHEN cep.[Enabled] = 1 THEN ''On'' WHEN cep.[Enabled] = 0 THEN ''Off'' ELSE ''Default'' END  as [Enabled]  
   , ''Email.'' + REPLACE(ett.[Name], '' '', '''')   as EmailType  
  FROM CustomerEmailPreference cep  
  INNER JOIN Lookup.EmailTemplateType ett ON ett.Id = cep.EmailType  
 ) AS SourceTable    
 PIVOT    
 (    
 MAX([Enabled])  
 FOR EmailType IN (' + @PivotCols_EmailTypes + '  )    
 ) AS PivotTable) as epp ON epp.CustomerId = c.Id  
'  
ELSE '' END +  
CASE WHEN @IncludeHierarchyColumns = 1 THEN   
'LEFT JOIN [Customer] parentCustomer on c.ParentId = parentCustomer.Id
' ELSE '' END +  
'where c.AccountId = @AccountId and c.IsDeleted = 0'

--print @SQL  
  
EXEC sp_executesql @SQL, N'@AccountId bigint, @Customers nvarchar(max)', @AccountId, @Customers  
  
END

GO

