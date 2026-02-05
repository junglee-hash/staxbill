
CREATE PROC [dbo].[usp_InsertAccountInvoicePreferenceLabel_HierarchyRollup]
	@AccountId BIGINT
AS 

IF NOT EXISTS (SELECT 1 FROM AccountInvoicePreferenceLabel 
			WHERE AccountInvoicePreferenceId = @AccountId AND InvoicePreferenceLabelId = 37)

BEGIN

	INSERT INTO [AccountInvoicePreferenceLabel] (
	[AccountInvoicePreferenceId]
	, [InvoicePreferenceLabelId]
	, [Label]
	, [ModifiedTimestamp])
	SELECT 
		@AccountId
		, Id
		, DefaultLabel
		, GETUTCDATE()
	FROM [Lookup].[InvoicePreferenceLabel]
	WHERE Id > 36 AND Id <= 47 --Rollup labels

END

GO

