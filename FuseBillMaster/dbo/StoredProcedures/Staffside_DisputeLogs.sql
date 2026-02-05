-- =============================================
-- Author:		Ilia Sazonov
-- Create date: 2025-06-09
-- Description:	Staffside query to get logs 
-- =============================================
CREATE   PROCEDURE [dbo].[Staffside_DisputeLogs] 
	-- Add the parameters for the stored procedure here
	@AccountId bigint,
	@CustomerId bigint
AS
BEGIN
	SET NOCOUNT ON;

	select * from DisputeLog
	where AccountId = @AccountId and CustomerId = @CustomerId
	order by CreatedTimestamp desc
END

GO

