CREATE PROC [dbo].[usp_DeleteCustomerAccountStatusJournal]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CustomerAccountStatusJournal]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

