
CREATE PROCEDURE [dbo].[usp_RecalculateCustomerHierarchy]
@CustomerId BIGINT
AS

SET NOCOUNT ON

DECLARE @IsParent BIT

SET @IsParent = CAST(
   CASE WHEN EXISTS(
		SELECT Id FROM Customer WHERE ParentId = @CustomerId AND IsDeleted = 0
		) THEN 1 
   ELSE 0 
   END 
AS BIT)

UPDATE Customer
	SET IsParent = @IsParent
WHERE Customer.Id = @CustomerId


SET NOCOUNT OFF

GO

