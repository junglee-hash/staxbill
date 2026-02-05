CREATE PROCEDURE [dbo].[usp_SoftDeleteSubscription]
	-- Add the parameters for the stored procedure here
	@Id bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Update Subscription
	SET IsDeleted = 1
	WHERE Id = @id

	UPDATE pf SET pf.NumberOfSubscriptions = pf.NumberOfSubscriptions - 1
	FROM PlanFrequency pf
	INNER JOIN Subscription s ON s.PlanFrequencyUniqueId = pf.PlanFrequencyUniqueId
	WHERE s.Id = @Id
END

GO

