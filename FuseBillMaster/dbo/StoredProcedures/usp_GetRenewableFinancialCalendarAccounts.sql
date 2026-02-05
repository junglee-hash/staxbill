CREATE   PROCEDURE [dbo].[usp_GetRenewableFinancialCalendarAccounts]
	@effectiveDate DATETIME
AS
BEGIN
	SET NOCOUNT ON;

    SELECT c.AccountId
	FROM Customer c
	INNER JOIN AccountFeatureConfiguration afc ON afc.Id = c.AccountId
		AND afc.ProjectedInvoiceEnabled = 1
	INNER JOIN Account a ON a.Id = c.AccountId
	LEFT JOIN [Address] adr ON adr.CustomerAddressPreferenceId = c.Id
	WHERE c.RequiresFinancialCalendarGeneration = 1
		AND a.IncludeInAutomatedProcesses = 1
		AND (adr.Id IS NULL OR adr.Invalid = 0) -- Exclude customers with invalid addresses
		AND (
			EXISTS(
			SELECT * 
			FROM Subscription s
			WHERE s.CustomerId = c.Id
			AND s.ModifiedTimestamp <= DATEADD(minute, afc.GenerateProjectedInvoicesDelay * -1, @effectiveDate)
			)
			OR c.IsParent = 1
		)
	GROUP BY c.AccountId, a.Live, a.Signed, a.FusebillTest
	ORDER BY a.Live DESC, a.Signed DESC, a.FusebillTest ASC
END

GO

