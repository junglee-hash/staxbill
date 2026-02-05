CREATE   PROCEDURE [dbo].[usp_GetTaxRules]
	@AccountId bigint
AS
BEGIN
	set transaction isolation level snapshot

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT * FROM TaxRule WHERE AccountId = @AccountId

	SELECT ex.*
	FROM TaxRuleProductExemption ex
	INNER JOIN TaxRule tr ON tr.Id = ex.TaxRuleId
	WHERE tr.AccountId = @AccountId
END

GO

