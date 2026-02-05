
CREATE PROCEDURE [dbo].[Staffside_StoredInStaxCards]
	@AccountId BIGINT
	,@StartDate DATETIME
	,@EndDate DATETIME
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select 
	pm.[CustomerId] as [Fusebill ID]
	,pm.Id as [Payment Method ID]
	,pm.[StoredInStax]
	,pm.[StoredInFusebillVault]
	,pm.[FirstName]
	,pm.[LastName]
	,CASE When pm.[Address1] is null or pm.[Address1]='' then 'No Address1' else 'Has Address1' END as [Address1]
	,CASE When pm.[City] is null or pm.[City]='' then 'No City' else 'Has City' END as [City]
	,CASE When pm.[StateId] is null  then 'No State' else 'Has State' END as [StateId]
	,CASE When pm.[CountryId] is null  then 'No Country' else 'Has Country' END as [CountryId]
	,CASE When pm.[PostalZip] is null or pm.[PostalZip]='' then 'No Zip' else 'Has Zip' END as [PostalZip]
	,pms.[Name] as [Payment Method Status]
	,pm.[AccountType]
	,pmt.[Name] as [Payment Method Type]
	,pm.[ModifiedTimestamp]
	,pm.[OriginalPaymentMethodId]
	,pm.[CreatedTimestamp]
from Customer c 
inner join PaymentMethod pm on pm.CustomerId = c.Id
inner join Lookup.PaymentMethodStatus pms on pms.Id = pm.PaymentMethodStatusId
inner join Lookup.PaymentMethodType pmt on pmt.Id = pm.PaymentMethodTypeId
where
	c.AccountId = @AccountId
	AND pm.ModifiedTimestamp >= @StartDate
	AND pm.ModifiedTimestamp < @EndDate
	AND pm.PaymentMethodStatusId = 1 --Active status

GO

