CREATE FUNCTION [dbo].[FullCustomerDataWithShipping]
(	
	@FusebillId as bigint,
	@AccountId as bigint,
	@CurrencyId as bigint,
	@UTCEndDateTime as datetime
)
RETURNS TABLE 
AS
RETURN 
(
	With EffectiveAccountingStatus as
(
Select 
	CustomerId
	, id
from (select  
		CustomerId
		, j.Id as Id,
		MAX(SequenceNumber) OVER(PARTITION BY CustomerId) AS maxSequence,
		SequenceNumber
	from 
		CustomerAccountStatusJournal j
		inner join Customer c
		on j.CustomerId = c.Id
	Where
		c.AccountId = @AccountId 
		and j.EffectiveTimestamp < @UTCEndDateTime 
		and ((c.CurrencyId = @CurrencyId) OR (@CurrencyId is null)) 
	) a
where maxSequence = SequenceNumber

)
,EffectiveCustomerStatus as
(
Select 
	CustomerId
	, id
from (select  
		CustomerId
		, j.Id as Id,
		MAX(SequenceNumber) OVER(PARTITION BY CustomerId) AS maxSequence,
		SequenceNumber
	from 
		CustomerStatusJournal j
		inner join Customer c
		on j.CustomerId = c.Id
	Where
		c.AccountId = @AccountId 
		and j.EffectiveTimestamp < @UTCEndDateTime 
		and ((c.CurrencyId = @CurrencyId) OR (@CurrencyId is null)) 
	) a
where maxSequence = SequenceNumber
)
	SELECT
		c.Id as [Fusebill ID]
	,isnull(c.Reference,'') as [Customer ID]
	,isnull(c.FirstName,'') as  [Customer First Name]
	,isnull(c.LastName,'') as [Customer Last Name]
	,isnull(c.CompanyName,'') as [Customer Company Name]
	,c.ParentId as [Customer Parent ID] -- standard stops here
	,c.QuickBooksId as [QuickBooks ID]
	,isnull(c.PrimaryPhone,'') as [Phone1]
	,isnull(c.SecondaryPhone,'') as [Phone2]
	,isnull(c.PrimaryEmail,'') as [Email1]
	,isnull(c.SecondaryEmail,'') as [Email2]
	,ISNULL(a.CompanyName, '') as [Contact Name]
	,ISNULL(cap.ShippingInstructions, '') as [Shipping Instructions]
	,isnull(a.Line1,'') as [Billing Address Line1]
	,isnull(a.Line2,'') as [Billing Address Line2]
	,isnull(co.Name,'') as [Billing Country]
	,isnull(st.Name,'') as [Billing State]
	,isnull(a.County,'') as [Billing County]
	,isnull(a.City,'') as [Billing City]
	,isnull(a.PostalZip,'') as [Billing Zip]
	,isnull(a2.Line1,'') as [Shipping Address Line1]
	,isnull(a2.Line2,'') as [Shipping Address Line2]
	,isnull(co2.Name,'') as [Shipping Country]
	,isnull(st2.Name,'') as [Shipping State]
	,isnull(a2.County,'') as [Shipping County]
	,isnull(a2.City,'') as [Shipping City]
	,isnull(a2.PostalZip,'') as [Shipping Zip]
	,isnull(cr.Reference1,'') as [Ref1]
	,isnull(cr.Reference2,'') as [Ref2]
	,isnull(cr.Reference3,'') as [Ref3]
	,isnull(stc1.Code,'') as [SalesTrackingCode1Code]
	,isnull(stc1.Name,'') as [SalesTrackingCode1Name]
	,isnull(stc2.Code,'') as [SalesTrackingCode2Code]
	,isnull(stc2.Name,'') as [SalesTrackingCode2Name]
	,isnull(stc3.Code,'') as [SalesTrackingCode3Code]
	,isnull(stc3.Name,'') as [SalesTrackingCode3Name]
	,isnull(stc4.Code,'') as [SalesTrackingCode4Code]
	,isnull(stc4.Name,'') as [SalesTrackingCode4Name]
	,isnull(stc5.Code,'') as [SalesTrackingCode5Code]
	,isnull(stc5.Name,'') as [SalesTrackingCode5Name]
	,isnull(cas.Name,'') as [Accounting Status (applicable at effective date of report)]
	,isnull(cs.Name,'') as [Status (applicable at effective date of report)]
	FROM Customer c
	left join CustomerAddressPreference cap	on c.Id = cap.Id
	left join Address a	on cap.Id = a.CustomerAddressPreferenceId and a.AddressTypeId = 1
	left join lookup.Country co	on a.CountryId = co.Id
	left join lookup.State st on a.StateId = st.Id
	LEFT JOIN Address a2 ON c.Id = a2.CustomerAddressPreferenceId AND a2.AddressTypeId = 2
	LEFT JOIN Lookup.State st2 ON st2.Id = a2.StateId
	LEFT JOIN Lookup.Country co2 ON co2.Id = a2.CountryId
	left join CustomerReference cr on c.Id = cr.Id 
	left join SalesTrackingCode stc1 on cr.SalesTrackingCode1Id = stc1.Id
	left join SalesTrackingCode stc2 on cr.SalesTrackingCode2Id = stc2.Id
	left join SalesTrackingCode stc3 on cr.SalesTrackingCode3Id = stc3.Id
	left join SalesTrackingCode stc4 on cr.SalesTrackingCode4Id = stc4.Id
	left join SalesTrackingCode stc5 on cr.SalesTrackingCode5Id = stc5.Id
	inner join EffectiveAccountingStatus eas on c.Id = eas.CustomerId 
	inner join CustomerAccountStatusJournal casj on eas.Id = casj.Id
	inner join lookup.CustomerAccountStatus cas	on casj.StatusId = cas.Id
	inner join EffectiveCustomerStatus ecs on c.Id = ecs.CustomerId 
	inner join CustomerStatusJournal csj on ecs.Id = csj.Id
	inner join lookup.CustomerStatus cs	on csj.StatusId = cs.Id
	WHERE c.Id = @FusebillId
)

GO

