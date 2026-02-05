CREATE PROC [dbo].[usp_DeleteCustomerStartingData]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CustomerStartingData]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

