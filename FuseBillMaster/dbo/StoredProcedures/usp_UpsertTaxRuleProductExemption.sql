
CREATE PROCEDURE [dbo].[usp_UpsertTaxRuleProductExemption]
	@AccountId BIGINT
	, @TaxRuleId BIGINT
	, @ProductIds VARCHAR(MAX)
AS

	declare @products table
	(
	ProductId bigint
	)

INSERT INTO @products (ProductId)
select Data from dbo.Split (@productIds,'|') as products
	inner join Product p on p.Id = products.Data
	where p.AccountId =
		CASE WHEN @accountId = 0 THEN
		 p.AccountId
		ELSE
		 @accountId
		End

	DELETE FROM TaxRuleProductExemption
	WHERE TaxRuleId = @TaxRuleId

	INSERT INTO TaxRuleProductExemption (TaxRuleId, ProductId)
	SELECT @TaxRuleId, ProductId
	FROM @products

GO

