
CREATE PROCEDURE [dbo].[Staffside_AutoUpdatedCards]
	@AccountId BIGINT
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select c.*, pm.Id as PaymentMethodId from Customer c 
inner join PaymentMethod pm on pm.CustomerId = c.Id
inner join CustomerBillingSetting cbs on cbs.Id = c.Id and cbs.DefaultPaymentMethodId = pm.Id
where pm.OriginalPaymentMethodId is not null 
and c.AccountId = @AccountId

GO

