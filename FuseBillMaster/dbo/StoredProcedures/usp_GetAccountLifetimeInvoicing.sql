-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[usp_GetAccountLifetimeInvoicing]
	@AccountId bigint
AS
BEGIN

;WITH AmountInvoiced AS
(
select 
    i.AccountId
    ,SUM(ij.SumOfCharges - ij.SumOfDiscounts + ij.SumOfTaxes) as NetInvoiced
from InvoiceJournal ij (NOLOCK) 
inner join Invoice i (NOLOCK) ON i.Id = ij.InvoiceId
where ij.isactive = 1
and ij.SumOfCharges > 0
and i.AccountId = @AccountId
group by i.AccountId
)
SELECT
    ai.AccountId
    ,ai.NetInvoiced
    ,CONVERT(Date, a.CreatedTimestamp) as StartDate
    ,CONVERT(Date, GETUTCDATE()) AS EndDate
FROM AmountInvoiced ai (NOLOCK)
INNER JOIN Account a (NOLOCK) on a.Id = ai.AccountId

End

GO

