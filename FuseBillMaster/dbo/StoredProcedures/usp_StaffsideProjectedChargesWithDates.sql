
CREATE Procedure [dbo].[usp_StaffsideProjectedChargesWithDates]
	@AccountId bigint
	,@StartDate datetime
	,@EndDate datetime
AS

SET TRANSACTION ISOLATION LEVEL SNAPSHOT
set nocount on

DECLARE @TimezoneId INT
SELECT @TimezoneId = TimezoneId
FROM AccountPreference WHERE Id = @AccountId 
		
SELECT 
	sp.Id as [Subscription Product ID]
	, COALESCE(spo.Name, sp.PlanProductName) as [Subscription Product Name]
	, COALESCE(so.Name, s.PlanName) as [Subscription Name]
	, s.Reference as [Subscription Reference]
	, dc.Amount as [Projected Charge Amount]
	, dc.Quantity as [Projected Quantity]
	, dc.UnitPrice as [Projected Unit Price]
	, dc.ProratedUnitPrice as [Projected Prorated Unit Price]
	, StartServiceDate.TimezoneDate as [Start Service Date]
	, EndServiceDate.TimezoneDate as [End Service Date]
	, EffectiveTimestamp.TimezoneDate as [Projected Posted Date]
	, di.Total as [Projected Invoice Total]
	, di.Id as [Projected Invoice ID]
	, s.BillingPeriodDefinitionId as [Billing Period Definition ID]
	, c.Id as [Fusebill ID]
	, c.Reference as [Customer Reference]
	, c.CompanyName as [Customer Company Name]
	, c.FirstName as [Customer First Name]
	, c.LastName as [Customer Last Name]
FROM DraftCharge dc
INNER JOIN DraftSubscriptionProductCharge dspc ON dc.Id = dspc.Id
INNER JOIN SubscriptionProduct sp ON sp.Id = dspc.SubscriptionProductId
INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
LEFT JOIN SubscriptionProductOverride spo ON spo.Id = sp.Id
LEFT JOIN SubscriptionOverride so ON so.Id = s.Id
INNER JOIN DraftInvoice di ON di.Id = dc.DraftInvoiceId
INNER JOIN Customer c ON c.Id = dc.CustomerId
CROSS APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, dspc.StartServiceDate) StartServiceDate
CROSS APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, dspc.EndServiceDate) EndServiceDate
CROSS APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, di.EffectiveTimestamp) EffectiveTimestamp

WHERE c.AccountId = @AccountId
	AND di.DraftInvoiceStatusId = 5
	AND di.EffectiveTimestamp >= @StartDate
	AND di.EffectiveTimestamp < @EndDate


set nocount off

GO

