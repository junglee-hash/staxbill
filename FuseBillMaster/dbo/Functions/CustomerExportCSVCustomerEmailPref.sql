
CREATE FUNCTION [dbo].[CustomerExportCSVCustomerEmailPref]
(	
	@FusebillId as bigint
)
RETURNS @CustEmailPrefCollection TABLE 
(
[Email - Customer Activation] varchar(5),
[Email - Credential Create] varchar(5),
[Email - Credential Password Reset] varchar(5),
[Email - Customer Suspend] varchar(5),
[Email - Draft Invoice] varchar(5),
[Email - Invoice Overdue] varchar(5),
[Email - Invoice Post] varchar(5),
[Email - Statement Notification] varchar(5),
[Email - Upcoming Billing Notification] varchar(5),
[Email - Credit Card Expiry] varchar(5),
[Email - Payment Failed] varchar(5),
[Email - Payment Method Update] varchar(5),
[Email - Payment Received] varchar(5),
[Email - Refund] varchar(5),
[Email - Pending Expiry Renewal Notice] varchar(5),
[Email - Subscription Activation] varchar(5),
[Email - Subscription Cancellation] varchar(5)
)

AS
BEGIN 

--declare        @AccountId bigint 
 	  -- , @FusebillId bigint

	--SET @AccountId=21;
	--SET @FusebillId=11016;


WITH CustEmailPrefs AS (
		SELECT ce.CustomerId, ce.EmailType, ce.[Enabled]
		FROM CustomerEmailPreference ce
		WHERE ce.CustomerId = @FusebillId)


	Insert @CustEmailPrefCollection ([Email - Customer Activation], [Email - Credential Create], [Email - Credential Password Reset],
										[Email - Customer Suspend], [Email - Draft Invoice], [Email - Invoice Overdue],
										[Email - Invoice Post], [Email - Statement Notification], [Email - Upcoming Billing Notification],
										[Email - Credit Card Expiry], [Email - Payment Failed], [Email - Payment Method Update],
										[Email - Payment Received], [Email - Refund], [Email - Pending Expiry Renewal Notice],
										[Email - Subscription Activation], [Email - Subscription Cancellation]  )

	SELECT 
	CASE WHEN COALESCE(cepca.Enabled, aetcepca.[Enabled]) = 1 THEN 'true' ELSE 'false' END
	,CASE WHEN COALESCE(cepcc.Enabled, aetcepcc.[Enabled]) = 1 THEN 'true' ELSE 'false' END 
	,CASE WHEN COALESCE(cepcpr.Enabled, aetcepcpr.[Enabled]) = 1 THEN 'true' ELSE 'false' END
	,CASE WHEN COALESCE(cepcs.Enabled, aetcepcs.[Enabled]) = 1 THEN 'true' ELSE 'false' END 
	,CASE WHEN COALESCE(cepdi.Enabled, aetcepdi.[Enabled]) = 1 THEN 'true' ELSE 'false' END 
	,CASE WHEN COALESCE(cepio.Enabled, aetcepio.[Enabled]) = 1 THEN 'true' ELSE 'false' END
	,CASE WHEN COALESCE(cepip.Enabled, aetcepip.[Enabled]) = 1 THEN 'true' ELSE 'false' END 
	,CASE WHEN COALESCE(cepsn.Enabled, aetcepsn.[Enabled]) = 1 THEN 'true' ELSE 'false' END 
	,CASE WHEN COALESCE(cepubn.Enabled, aetcepubn.[Enabled]) = 1 THEN 'true' ELSE 'false' END 
	,CASE WHEN COALESCE(cepcce.Enabled, aetcepcce.[Enabled]) = 1 THEN 'true' ELSE 'false' END 
	,CASE WHEN COALESCE(ceppf.Enabled, aetceppf.[Enabled]) = 1 THEN 'true' ELSE 'false' END
	,CASE WHEN COALESCE(ceppmu.Enabled, aetceppmu.[Enabled]) = 1 THEN 'true' ELSE 'false' END  
	,CASE WHEN COALESCE(ceppr.Enabled, aetceppr.[Enabled]) = 1 THEN 'true' ELSE 'false' END
	,CASE WHEN COALESCE(cepr.Enabled, aetcepr.[Enabled]) = 1 THEN 'true' ELSE 'false' END 
	,CASE WHEN COALESCE(ceppern.Enabled, aetceppern.[Enabled]) = 1 THEN 'true' ELSE 'false' END 
	,CASE WHEN COALESCE(cepsa.Enabled, aetcepsa.[Enabled]) = 1 THEN 'true' ELSE 'false' END  
	,CASE WHEN COALESCE(cepsc.Enabled, aetcepsc.[Enabled]) = 1 THEN 'true' ELSE 'false' END  


	FROM
	Customer c 
	-- Get all email preferences set for the customer
	LEFT JOIN CustEmailPrefs cepca on cepca.EmailType = 7
	LEFT JOIN CustEmailPrefs cepcc on cepcc.EmailType = 10
	LEFT JOIN CustEmailPrefs cepcpr on cepcpr.EmailType = 11
	LEFT JOIN CustEmailPrefs cepcs on cepcs.EmailType = 12
	LEFT JOIN CustEmailPrefs cepdi on cepdi.EmailType = 21
	LEFT JOIN CustEmailPrefs cepio on cepio.EmailType = 3
	LEFT JOIN CustEmailPrefs cepip on cepip.EmailType = 1
	LEFT JOIN CustEmailPrefs cepsn on cepsn.EmailType = 15
	LEFT JOIN CustEmailPrefs cepubn on cepubn.EmailType = 16
	LEFT JOIN CustEmailPrefs cepcce on cepcce.EmailType = 14
	LEFT JOIN CustEmailPrefs ceppf on ceppf.EmailType = 6
	LEFT JOIN CustEmailPrefs ceppmu on ceppmu.EmailType = 13
	LEFT JOIN CustEmailPrefs ceppr on ceppr.EmailType = 2
	LEFT JOIN CustEmailPrefs cepr on cepr.EmailType = 17
	LEFT JOIN CustEmailPrefs ceppern on ceppern.EmailType = 18
	LEFT JOIN CustEmailPrefs cepsa on cepsa.EmailType = 8
	LEFT JOIN CustEmailPrefs cepsc on cepsc.EmailType = 9
	LEFT JOIN AccountEmailTemplate aetcepca on aetcepca.AccountId = c.AccountId and aetcepca.TypeId = cepca.EmailType
	LEFT JOIN AccountEmailTemplate aetcepcc on aetcepcc.AccountId = c.AccountId and aetcepcc.TypeId = cepcc.EmailType
	LEFT JOIN AccountEmailTemplate aetcepcpr on aetcepcpr.AccountId = c.AccountId and aetcepcpr.TypeId = cepcpr.EmailType
	LEFT JOIN AccountEmailTemplate aetcepcs on aetcepcs.AccountId = c.AccountId and aetcepcs.TypeId = cepcs.EmailType
	LEFT JOIN AccountEmailTemplate aetcepdi on aetcepdi.AccountId = c.AccountId and aetcepdi.TypeId = cepdi.EmailType
	LEFT JOIN AccountEmailTemplate aetcepio on aetcepio.AccountId = c.AccountId and aetcepio.TypeId = cepio.EmailType
	LEFT JOIN AccountEmailTemplate aetcepip on aetcepip.AccountId = c.AccountId and aetcepip.TypeId = cepip.EmailType
	LEFT JOIN AccountEmailTemplate aetcepsn on aetcepsn.AccountId = c.AccountId and aetcepsn.TypeId = cepsn.EmailType
	LEFT JOIN AccountEmailTemplate aetcepubn on aetcepubn.AccountId = c.AccountId and aetcepubn.TypeId = cepubn.EmailType
	LEFT JOIN AccountEmailTemplate aetcepcce on aetcepcce.AccountId = c.AccountId and aetcepcce.TypeId = cepcce.EmailType
	LEFT JOIN AccountEmailTemplate aetceppf on aetceppf.AccountId = c.AccountId and aetceppf.TypeId = ceppf.EmailType
	LEFT JOIN AccountEmailTemplate aetceppmu on aetceppmu.AccountId = c.AccountId and aetceppmu.TypeId = ceppmu.EmailType
	LEFT JOIN AccountEmailTemplate aetceppr on aetceppr.AccountId = c.AccountId and aetceppr.TypeId = ceppr.EmailType
	LEFT JOIN AccountEmailTemplate aetcepr on aetcepr.AccountId = c.AccountId and aetcepr.TypeId = cepr.EmailType
	LEFT JOIN AccountEmailTemplate aetceppern on aetceppern.AccountId = c.AccountId and aetceppern.TypeId = ceppern.EmailType
	LEFT JOIN AccountEmailTemplate aetcepsa on aetcepsa.AccountId = c.AccountId and aetcepsa.TypeId = cepsa.EmailType
	LEFT JOIN AccountEmailTemplate aetcepsc on aetcepsc.AccountId = c.AccountId and aetcepsc.TypeId = cepsc.EmailType

	WHERE c.Id = @FusebillId

RETURN
END

GO

