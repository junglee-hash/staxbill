
CREATE   PROCEDURE [dbo].[Staffside_PaymentActivityPrimaryGatewayFailureByAccount]
	@AccountId BIGINT
	,@StartDate DATETIME
	,@EndDate DATETIME
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select 
	paj.CustomerId as [Fusebill ID]
	,paj.Id as [Payment Activity ID]	
	,paj.PaymentMethodId as [Payment Method ID]
	,paj.PrimaryGatewayFailure as [Primary Gateway Failure]
	,pas.[Name] as [Payment Status]
	,paj.ReconciliationId
	,pmt.[Name] as [Paymnent Method Type]	
	,pt.[Name] as [Payment Type]
	,paj.AttemptNumber
	,paj.GatewayName as [Successful Gateway]
	,paj.GatewayId as [Successful Gateway ID]
	,paj.ModifiedTimestamp
	,paj.AuthorizationResponse
	,paj.[Trigger]
	,paj.TriggeringUserId
from PaymentActivityJournal paj
inner join Customer c on c.Id = paj.CustomerId
inner join Lookup.PaymentActivityStatus pas on pas.Id = paj.PaymentActivityStatusId
inner join Lookup.PaymentMethodType pmt on pmt.Id = paj.PaymentMethodTypeId
inner join Lookup.PaymentType pt on pt.Id = paj.PaymentTypeId
where 
c.AccountId = @AccountId 
AND paj.PrimaryGatewayFailure IS NOT NULL
AND paj.ModifiedTimestamp >= @StartDate
AND paj.ModifiedTimestamp < @EndDate

GO

