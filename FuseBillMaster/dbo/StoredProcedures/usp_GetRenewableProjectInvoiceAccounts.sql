CREATE   PROCEDURE [dbo].[usp_GetRenewableProjectInvoiceAccounts]
    @effectiveDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CustomerId, MIN(ModifiedTimeStamp) as 'MinModifiedTimestamp'
    INTO #tmp1
    FROM Subscription
    GROUP BY 
        CustomerId

    CREATE INDEX idx1 ON #tmp1(CustomerId)

    SELECT c.AccountId
    FROM Customer c
    INNER JOIN AccountFeatureConfiguration afc ON afc.Id = c.AccountId
        AND afc.ProjectedInvoiceEnabled = 1
    INNER JOIN Account a ON a.Id = c.AccountId
	INNER JOIN AccountAddressPreference aap ON aap.Id = c.AccountId
    LEFT JOIN [Address] adr ON adr.CustomerAddressPreferenceId = c.Id 
		AND adr.AddressTypeId = CASE WHEN aap.UseCustomerBillingAddress = 1 THEN 1 ELSE 2 END
    WHERE c.RequiresProjectedInvoiceGeneration = 1
		AND a.IncludeInAutomatedProcesses = 1
        AND (adr.Id IS NULL OR adr.Invalid = 0) -- Exclude customers with invalid addresses
        AND (
            EXISTS(
                SELECT *
                FROM #tmp1 s
                WHERE s.CustomerId = c.Id
                AND s.MinModifiedTimestamp <= DATEADD(minute, afc.GenerateProjectedInvoicesDelay * -1, @effectiveDate)
            )
            OR c.IsParent = 1 
        )
    GROUP BY c.AccountId, a.Live, a.Signed, a.FusebillTest
    ORDER BY a.Live DESC, a.Signed DESC, a.FusebillTest ASC

   
    DROP TABLE #tmp1

 END

GO

