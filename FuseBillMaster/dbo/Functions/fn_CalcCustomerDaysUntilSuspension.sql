
CREATE FUNCTION [dbo].[fn_CalcCustomerDaysUntilSuspension]
(
	@CustomerAccountStatusId int,
	@CustomerAccountStatus nvarchar(50),
	@CustomerStatusId int,
	@CustomerStatus nvarchar(50),
	@CustomerGracePeriod int = null,
	@AccountGracePeriod int = null,
	@CustomerGracePeriodExtention int = null,
	@MostRecentCustomerStatusJournalEffectiveDate DateTime
)
RETURNS int
AS
BEGIN
	DECLARE @ResultDaysUntilSuspension int

	SELECT @ResultDaysUntilSuspension = 
		CASE WHEN ((ISNULL(@CustomerAccountStatusId, 0) = 2) OR (ISNULL(@CustomerAccountStatus, '') = 'PoorStanding')) AND ((ISNULL(@CustomerStatusId, 0) = 2) OR (ISNULL(@CustomerStatus, '') = 'Active')) 
			THEN str( (isnull(@CustomerGracePeriod,   isnull(@AccountGracePeriod, 0)) + isnull(@CustomerGracePeriodExtention, 0) - (DATEDIFF(d, @MostRecentCustomerStatusJournalEffectiveDate, GETUTCDATE())))) 
			ELSE '' 
		END 

	RETURN @ResultDaysUntilSuspension

END

GO

