CREATE PROC [dbo].[usp_DeleteCustomerAcquisition]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CustomerAcquisition]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

