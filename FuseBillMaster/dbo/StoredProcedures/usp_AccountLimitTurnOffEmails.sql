Create PROC [dbo].[usp_AccountLimitTurnOffEmails]

	@AccountId bigint

AS

BEGIN

--Set all account emails off
Update [dbo].[AccountEmailTemplate] set [Enabled] = 0 where AccountId = @AccountId

--Set Customer emails to account default
update cep
set cep.[Enabled] = null 
from [dbo].[CustomerEmailPreference] cep
    inner join [dbo].[Customer] cust on cust.Id = cep.CustomerId
	where cust.AccountId = @AccountId

END

GO

