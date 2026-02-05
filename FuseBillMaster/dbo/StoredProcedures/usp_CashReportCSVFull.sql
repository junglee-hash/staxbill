
CREATE   procedure [dbo].[usp_CashReportCSVFull]
@AccountId bigint 
,@StartDate datetime 
,@EndDate datetime 
,@CurrencyId bigint = 1 
,@SalesTrackingCodeType BIGINT = NULL
,@SalesTrackingCodeId BIGINT = NULL
AS

/*
Payment reference
Payment Source (Automatic/Manual)
Payment Type (Payment, Full Refund, Partial Refund)
Payment Method (Credit Card, ACH, Cash, Check)
Payment Method Type (Chq, Sav,Visa,MasterCard,Amex,Discover,other)
Gateway (empty for Cash or Check)
Gateway Reference (empty for cash or check)
Related Payment ID (holds the original payment id for refunds)
Amount
Currency
*/

set transaction isolation level snapshot

declare @TimezoneId int
declare @ShowFirstSix bit

select @TimezoneId = TimezoneId
from AccountPreference where Id = @AccountId 

select @ShowFirstSix = ShowFirstSix
from AccountFeatureConfiguration where Id = @AccountId

SELECT * INTO #CustomerData
FROM dbo.FullCustomerDataByAccount(@AccountId,@CurrencyId,@EndDate)


SELECT
	convert(smalldatetime,dbo.fn_GetTimezoneTime(t.EffectiveTimestamp,@TimezoneId )) as [Payment Effective Date]
	,isnull(coalesce(p.Reference,r.Reference),'' ) as [Payment Reference]
	,coalesce(p.ReferenceDate,r.ReferenceDate) as [Payment Reference Date]
	,t.Id as [Payment Transaction ID]
	,isnull(ps.Name,'') as [Payment Source]
	--,isnull(pt.Name,'') as [Payment Type]
	,isnull(case when (pt.Id = 3 and tt.Id = 5) OR tt.Id = 25 then tt.Name else pt.Name End,'') as [Payment Type]
	,isnull(pmt.Name,'') as [Payment Method Type]
	,isnull(pm.AccountType,isnull(pmt.Name,'')) as [Payment Method]
	,case when @ShowFirstSix = 1 and cc.FirstSix is not null then COALESCE(cc.FirstSix + '****' + cc.MaskedCardNumber,'****' + ac.MaskedAccountNumber,'') else COALESCE('****' + cc.MaskedCardNumber,'****' + ac.MaskedAccountNumber,'') end as [Payment Method Detail]
	,isnull(paj.GatewayName ,'') as Gateway
	,isnull(paj.AuthorizationCode ,'') as [Gateway Reference]
	,isnull(convert(varchar(50),r.OriginalPaymentId ),'') as [Related Payment ID]
	,t.Amount * -tt.ARBalanceMultiplier as Amount
	,cur.IsoName as Currency
	,paj.ParentCustomerId as [Parent Payment Method ID]
	,convert(varchar(50),coalesce(p.NetsuiteId, r.NetsuiteId)) as [Netsuite Id]
	--,Customer.*
	,t.CustomerId
	,paj.AttemptNumber as [Retry Count]
	,paj.SecondaryTransactionNumber as [Gateway Reference 2]
	,paj.ReconciliationId as [Reconciliation ID]
	,invNumb.InvoiceNumbers as [Invoice Allocation]
	,ISNULL(paj.[Trigger], '') as [Trigger]
	,case when paj.TriggeringUserId is null then '' else (u.FirstName + ' ' + u.LastName) end as [Triggering User]
INTO #Results
From
	[Transaction] t
	inner join lookup.TransactionType tt on t.TransactionTypeId = tt.Id 
	inner join lookup.Currency cur on t.CurrencyId = cur.Id 
	left join Payment p on t.Id = p.Id
	left join Refund r on t.Id = r.Id
	left join Payment op on op.Id = r.OriginalPaymentId
	inner join PaymentActivityJournal paj on coalesce(p.PaymentActivityJournalId, r.PaymentActivityJournalId) = paj.Id
	left join Lookup.PaymentSource ps on paj.PaymentSourceId = ps.Id
	left join lookup.PaymentType pt on paj.PaymentTypeId = pt.Id 
	left join lookup.PaymentMethodType pmt on paj.PaymentMethodTypeId = pmt.Id
	left join PaymentMethod pm on paj.PaymentMethodId = pm.Id
	left join (SELECT
        PaymentId
        ,STUFF(
            (SELECT Distinct ', ' + CONVERT(VARCHAR(20),i.InvoiceNumber)
            FROM PaymentNote pn2
            JOIN Invoice i ON pn2.InvoiceId = i.Id
            WHERE pn2.PaymentId = pn.PaymentId
            ORDER BY 1
                FOR XML PATH('')),1,2,'') AS InvoiceNumbers
        FROM PaymentNote pn
        GROUP BY PaymentId) invNumb
	on invNumb.PaymentId = p.Id
	LEFT JOIN CreditCard cc ON cc.Id = pm.Id
	LEFT JOIN AchCard ac ON ac.Id = pm.Id
	left join [User] u on u.Id = paj.TriggeringUserId
Where 
	t.AccountId = @AccountId 
	and t.EffectiveTimestamp >= @StartDate 
	and t.EffectiveTimestamp < @EndDate 
	and t.TransactionTypeId in(3,4,5,25)
	and t.CurrencyId = @CurrencyId 
	and paj.PaymentActivityStatusId NOT IN (2,3) -- failed, unknown
		-- NEED TO ISNULL because the = doesn't work when the value is NULL, e.g. NULL = NULL
		-- doesn't return a value
		AND COALESCE(p.SalesTrackingCode1Id, op.SalesTrackingCode1Id, 0) =
			CASE WHEN @SalesTrackingCodeType = 1 THEN @SalesTrackingCodeId
			ELSE COALESCE(p.SalesTrackingCode1Id, op.SalesTrackingCode1Id, 0)
			END
		AND COALESCE(p.SalesTrackingCode2Id, op.SalesTrackingCode2Id, 0) =
			CASE WHEN @SalesTrackingCodeType = 2 THEN @SalesTrackingCodeId
			ELSE COALESCE(p.SalesTrackingCode2Id, op.SalesTrackingCode2Id, 0)
			END
		AND COALESCE(p.SalesTrackingCode3Id, op.SalesTrackingCode3Id, 0) =
			CASE WHEN @SalesTrackingCodeType = 3 THEN @SalesTrackingCodeId
			ELSE COALESCE(p.SalesTrackingCode3Id, op.SalesTrackingCode3Id, 0)
			END
		AND COALESCE(p.SalesTrackingCode4Id, op.SalesTrackingCode4Id, 0) =
			CASE WHEN @SalesTrackingCodeType = 4 THEN @SalesTrackingCodeId
			ELSE COALESCE(p.SalesTrackingCode4Id, op.SalesTrackingCode4Id, 0)
			END
		AND COALESCE(p.SalesTrackingCode5Id, op.SalesTrackingCode5Id, 0) =
			CASE WHEN @SalesTrackingCodeType = 5 THEN @SalesTrackingCodeId
			ELSE COALESCE(p.SalesTrackingCode5Id, op.SalesTrackingCode5Id, 0)
			END

SELECT * 
FROM #Results r
INNER JOIN #CustomerData c ON c.[Fusebill Id] = r.CustomerId

DROP TABLE #Results
DROP TABLE #CustomerData

GO

