CREATE PROC [dbo].[usp_DeleteCustomerEmailLog]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CustomerEmailLog]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

