
CREATE PROCEDURE [dbo].[usp_DeleteAuditTrail]

AS
SET NOCOUNT ON
DELETE
	a
FROM 
	AuditTrail a 
WHERE 
	Id IN
	(
		SELECT 
			TOP 1000 Id 
		FROM 
			AuditTrail a WITH (NOLOCK)
		WHERE 
			a.LogExpiryTimestamp < GETUTCDATE()
	)

SET NOCOUNT OFF

GO

