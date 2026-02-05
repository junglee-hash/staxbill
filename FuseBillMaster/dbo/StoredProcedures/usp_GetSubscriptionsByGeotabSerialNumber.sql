CREATE   PROCEDURE [dbo].[usp_GetSubscriptionsByGeotabSerialNumber]

	@SerialNumbers AS GeotabDeviceList readonly,
	@SerialNumberField varchar(50),
	@AccountId bigint

AS

	SET XACT_ABORT, NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SELECT SerialNumber INTO #SerialNumbersTemp FROM @SerialNumbers
	CREATE CLUSTERED INDEX IX_SerialNumbersTemp ON #SerialNumbersTemp (SerialNumber);


	SELECT DISTINCT ss.SerialNumber
    FROM Subscription s
    INNER JOIN SubscriptionOverride so ON so.Id = s.Id
    CROSS APPLY #SerialNumbersTemp ss
    WHERE s.AccountId = @AccountId
	  AND s.StatusId NOT IN (3,7) -- Cancelled, migrated
      AND
      CASE @SerialNumberField
          WHEN 'Name' THEN so.Name
          WHEN 'Description' THEN so.Description
          ELSE s.Reference
      END = ss.SerialNumber


	DROP TABLE #SerialNumbersTemp

GO

