CREATE PROC [dbo].[usp_DeleteCustomerStatusJournal]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CustomerStatusJournal]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

