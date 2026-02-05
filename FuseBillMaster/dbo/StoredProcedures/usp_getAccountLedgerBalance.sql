
CREATE PROCEDURE [dbo].[usp_getAccountLedgerBalance]
	@AccountId bigint,
	@CurrencyId bigint,
	@StartDate datetime,
	@EndDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	SET NOCOUNT ON;

    SELECT 
		tl.AccountId AS Id
		,tl.CurrencyId
		,SUM(tl.ArDebit) AS AccountsReceivableBalanceDebit
		,SUM(tl.ArCredit) AS AccountsReceivableBalanceCredit
		,SUM(tl.CashDebit) AS CashCollectedDebit
		,SUM(tl.CashCredit) AS CashCollectedCredit
		,SUM(tl.EarnedDebit) AS EarnedBalanceDebit
		,SUM(tl.EarnedCredit) AS EarnedBalanceCredit
		,SUM(tl.UnearnedDebit) AS UnearnedBalanceDebit
		,SUM(tl.UnearnedCredit) AS UnearnedBalanceCredit
		,SUM(tl.WriteOffDebit) AS WriteOffBalanceDebit
		,SUM(tl.WriteOffCredit) AS WriteOffBalanceCredit
		,SUM(tl.TaxesPayableDebit) AS TaxesPayableBalanceDebit
		,SUM(tl.TaxesPayableCredit)  AS TaxesPayableBalanceCredit
		,SUM(tl.DiscountDebit) AS DiscountBalanceDebit
		,SUM(tl.DiscountCredit) AS DiscountBalanceCredit
		,SUM(tl.OpeningBalanceDebit) AS OpeningBalanceDebit
		,SUM(tl.OpeningBalanceCredit) AS OpeningBalanceCredit
		,SUM(tl.CreditDebit) AS CreditDebit
		,SUM(tl.CreditCredit) AS CreditCredit
		,SUM(tl.UnearnedDiscountDebit) AS UnearnedDiscountBalanceDebit
		,SUM(tl.UnearnedDiscountCredit) AS UnearnedDiscountBalanceCredit
		,SUM(tl.OpeningDeferredRevenueDebit) AS OpeningDeferredRevenueDebit
		,SUM(tl.OpeningDeferredRevenueCredit) AS OpeningDeferredRevenueCredit
	FROM dbo.tvf_TransactionLedgers (@AccountId,@CurrencyId,@StartDate,@EndDate) tl
	GROUP BY tl.AccountId,tl.CurrencyId

	SET NOCOUNT OFF;
END

GO

