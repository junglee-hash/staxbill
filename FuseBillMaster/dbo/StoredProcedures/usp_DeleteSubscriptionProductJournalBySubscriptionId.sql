-- =============================================
-- Author:		dlarkin
-- Create date: 2019-01-04
-- Description:	delete subscription product journal by subscription id
-- =============================================
CREATE PROCEDURE [dbo].[usp_DeleteSubscriptionProductJournalBySubscriptionId] 
	-- Add the parameters for the stored procedure here
	@SubscriptionId bigint = -1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE spj
	FROM SubscriptionProductJournal spj
	INNER JOIN SubscriptionProduct sp on spj.SubscriptionProductId = sp.id
	WHERE sp.SubscriptionId = @SubscriptionId

END

GO

