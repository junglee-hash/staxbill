CREATE   PROCEDURE [dbo].[usp_GetRenewableProjectInvoiceCustomers]
	@accountId BIGINT,
	@effectiveDate DATETIME
AS
BEGIN
	SET NOCOUNT ON;

    SELECT DISTINCT c.Id
	FROM Customer c
	INNER JOIN AccountFeatureConfiguration afc ON afc.Id = c.AccountId
		AND afc.ProjectedInvoiceEnabled = 1
	INNER JOIN AccountAddressPreference aap ON aap.Id = c.AccountId
	LEFT JOIN [Address] adr ON adr.CustomerAddressPreferenceId = c.Id
		AND adr.AddressTypeId = CASE WHEN aap.UseCustomerBillingAddress = 1 THEN 1 ELSE 2 END
	WHERE c.RequiresProjectedInvoiceGeneration = 1
		AND c.AccountId = @accountId
		AND (
			(adr.Id IS NULL OR adr.Invalid = 0) -- Exclude customers with invalid addresses
			AND EXISTS(
				SELECT * 
				FROM Subscription s
				WHERE s.CustomerId = c.Id
				AND s.ModifiedTimestamp <= DATEADD(minute, afc.GenerateProjectedInvoicesDelay * -1, @effectiveDate)
			) OR c.IsParent = 1
		)
END

GO

