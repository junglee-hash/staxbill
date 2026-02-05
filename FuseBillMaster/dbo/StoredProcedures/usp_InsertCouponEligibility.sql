 
 
CREATE PROC [dbo].[usp_InsertCouponEligibility]

	@StartDate datetime,
	@EndDate datetime
AS
SET NOCOUNT ON
	INSERT INTO [CouponEligibility] (
		[StartDate],
		[EndDate]
	)
	VALUES (
		@StartDate,
		@EndDate
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

