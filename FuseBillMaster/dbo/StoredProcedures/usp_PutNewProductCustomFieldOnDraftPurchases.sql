
CREATE PROCEDURE [dbo].[usp_PutNewProductCustomFieldOnDraftPurchases]
	@ProductId bigint,
	@CustomFieldId bigint,
	@DefaultStringValue nvarchar(1000),
	@DefaultDateValue datetime,
	@DefaultNumericValue decimal(18,6)
AS
BEGIN TRY
	SET NOCOUNT ON;

    INSERT INTO [dbo].[PurchaseCustomField] (CustomFieldId, PurchaseId, StringValue, DateValue, NumericValue, CreatedTimestamp, ModifiedTimestamp)
	SELECT @CustomFieldId, Id, @DefaultStringValue, @DefaultDateValue, @DefaultNumericValue, GETUTCDATE(), GETUTCDATE() FROM Purchase
	WHERE StatusId = 1 AND ProductId = @ProductId

	select 1 -- tell EF it's done!

	SET NOCOUNT OFF
	RETURN 0
END TRY

BEGIN CATCH
	IF XACT_STATE() <> 0   ROLLBACK TRANSACTION;
	
	Return 1
END CATCH
SET NOCOUNT OFF

GO

