-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	To test how we handle errors generated via sql
-- =============================================
CREATE PROCEDURE [dbo].[usp_Testing_ThrowSQLException]
	@ErrorType int = 0
AS
BEGIN

	SET NOCOUNT ON;
	--if we need to raise errors with specific information or structure, add a new @errorType and if statement
	If @ErrorType = 0 
			RAISERROR (15600,-1,-1, 'mysp_CreateCustomer');
		ELSE
			RAISERROR (15600,-1,-1, 'mysp_CreateCustomer');
	
END

GO

