
CREATE FUNCTION [dbo].[fn_CalcCustomerGracePeriod] 
(
	@CustomerGracePeriod int = null,
	@AccountGracePeriod int = null,
	@CustomerExtension int = null
)
RETURNS int
AS
BEGIN
	DECLARE @ResultCustomerGracePeriod int

	SELECT @ResultCustomerGracePeriod = ISNULL(@CustomerGracePeriod, ISNULL(@AccountGracePeriod, 0)) + ISNULL(@CustomerExtension, 0)

	RETURN @ResultCustomerGracePeriod

END

GO

