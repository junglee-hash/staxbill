CREATE PROCEDURE [dbo].[usp_GetCustomerReportCSV]
	@AccountId bigint 
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	
	SET NOCOUNT ON;
		
	SELECT * FROM dbo.[CustomerExportFull] (@AccountId)

END

GO

