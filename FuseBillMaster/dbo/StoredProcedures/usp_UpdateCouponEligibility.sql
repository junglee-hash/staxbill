CREATE PROC [dbo].[usp_UpdateCouponEligibility]

	@Id bigint,
	@StartDate datetime,
	@EndDate datetime
AS
SET NOCOUNT ON
	UPDATE [CouponEligibility] SET 
		[StartDate] = @StartDate,
		[EndDate] = @EndDate
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

