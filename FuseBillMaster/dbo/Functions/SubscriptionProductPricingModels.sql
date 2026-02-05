CREATE FUNCTION [dbo].[SubscriptionProductPricingModels]
(	
	
	@AccountId as bigint
)
RETURNS @ranges TABLE 
(
Spprid bigint,
TRange NVARCHAR(255),
TPrice NVARCHAR(255)
)
AS

BEGIN

	--Declare @AccountId bigint
	--Set @AccountId = 21

	DECLARE @Templine TABLE ([Subscription Product ID] VARCHAR(255))
	DECLARE @tmpline TABLE (SubProdId bigint, Mmin float, Mmax float, Price DECIMAL(10,2))
	--DECLARE @ranges TABLE (Spprid bigint, TRange NVARCHAR(255), TPrice NVARCHAR(255))

	Insert @Templine ([Subscription Product ID])
	SELECT 
		sp.Id 
       FROM Product p
        INNER JOIN SubscriptionProduct sp ON p.Id = sp.ProductId
        INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
        INNER JOIN Customer c ON c.Id = s.CustomerId and c.AccountId = @AccountId ;

	Insert @tmpline (SubProdId, Mmin, Mmax, Price)
	select pro.PricingModelOverrideId as SubProdId, pro.[Min] as Mmin, pro.[Max] as Mmax, pro.Price as Price 
	 from dbo.PriceRangeOverride pro
	where pro.PricingModelOverrideId in ( select [Subscription Product ID] from @Templine );

	Insert into @tmpline(SubProdId, Mmin, Mmax, Price)
	select sppr.SubscriptionProductId AS [SubProdId], sppr.[Min] AS [Mmin], sppr.[Max] AS [Mmax], sppr.Amount AS [Price]
	from dbo.SubscriptionProductPriceRange sppr
	where sppr.SubscriptionProductId in ( select [Subscription Product ID] from @Templine where [Subscription Product ID] not in ( select distinct SubProdId from @tmpline ) ) ;

	Insert @ranges (Spprid, TRange, TPrice)
	Select Main.SubProdId as spprid, 
	CASE WHEN Main.TRange = '>0 |' THEN '' ELSE Left(Main.TRange,Len(Main.TRange)-1) END as  "TRange",
	Left(Main.TPrice,Len(Main.TPrice)-1) as "TPrice"
		From (
	Select distinct SPPR2.SubProdId,
	(
		Select 
		CASE WHEN SPPR1.Mmax IS NULL 
			THEN '>' + CONVERT(nvarchar(20),Cast(SPPR1.Mmin as float))  + ' | ' 
			ELSE CONVERT(nvarchar(20),Cast(SPPR1.Mmin as float)) + '-' + CONVERT(nvarchar(20), cast(SPPR1.Mmax as float)) + ' | ' 
		END	As [text()]
		From @tmpline SPPR1
		Where SPPR2.SubProdId = SPPR1.SubProdId 
				  
		order by SPPR1.SubProdId, SPPR1.Mmin Asc
				  
		-- Ensure Special Characters Come Out OK
		For XML PATH (''), root('MyString'), type 
	).value('/MyString[1]','varchar(max)') [TRange],
	(
		Select  
			cc.Symbol + CONVERT(nvarchar(20),CONVERT(DECIMAL(10,2),SPPR1.Price )) + ' | '  As [text()]
		From @tmpline SPPR1
		inner join dbo.SubscriptionProduct sp on sp.Id = SPPR1.SubProdId
		inner join dbo.Subscription s on s.id = sp.SubscriptionId
		inner Join dbo.customer c on c.id = s.CustomerId
		inner join Lookup.Currency cc on cc.Id = c.CurrencyId
		Where SPPR2.SubProdId = SPPR1.SubProdId 
		order by SPPR1.SubProdId, SPPR1.Mmin Asc
		-- Ensure Special Characters Come Out OK
		For XML PATH (''), root('MyString'), type 
	).value('/MyString[1]','varchar(max)') [TPrice]

	From @tmpline SPPR2
	) [MAIN] 

	RETURN 

END

GO

