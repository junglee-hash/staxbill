
CREATE PROCEDURE [dbo].[usp_DeleteTaxRuleFull]
	@Id BIGINT
AS
SET NOCOUNT ON;
	BEGIN

	DELETE FROM TaxRuleProductExemption 
	WHERE taxRuleId = @Id
	
	
	DELETE FROM TaxRule 
	WHERE Id = @Id
	
	END
SET NOCOUNT OFF;

GO

