CREATE     PROCEDURE [dbo].[usp_GetRenewableCustomers]
@RunDateTime DATETIME = NULL,
@AccountId BIGINT ,
@LargeAccountThreshold INT = 100000,
@Debug_PrintQuery TINYINT = 0 
AS
BEGIN
	
	SET NOCOUNT ON
	DECLARE	@UtcPeriodEndDateTime DATETIME;

	IF EXISTS (
		SELECT	1
		FROM	Account
		WHERE	Id = @AccountId
			AND IncludeInAutomatedProcesses = 0
	)
	BEGIN
		SELECT	CustomerId = CONVERT(BIGINT,NULL),
				UtcPeriodEndDateTime = CONVERT(DATETIME,NULL),
				NetMRR = CONVERT(MONEY,NULL) 
		RETURN
	END
	ELSE
	BEGIN
		DECLARE @customers INT
		SELECT @customers = [Active Customers] FROM Reporting.AccountProfile
		WHERE [Account ID] = @AccountId

		IF (ISNULL(@customers,0) > @LargeAccountThreshold)
		BEGIN
			EXEC [usp_GetRenewableCustomers_B2C] @RunDateTime, @AccountId, @LargeAccountThreshold, @Debug_PrintQuery
		END
		ELSE
		BEGIN
			EXEC [usp_GetRenewableCustomers_General] @RunDateTime, @AccountId, @LargeAccountThreshold, @Debug_PrintQuery
		END
		
	END
END

GO

