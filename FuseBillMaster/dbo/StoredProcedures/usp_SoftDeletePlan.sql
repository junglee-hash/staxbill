

CREATE     PROCEDURE [dbo].[usp_SoftDeletePlan]
	@Id bigint
AS
SET NOCOUNT ON

UPDATE [dbo].[Plan]
SET IsDeleted = 1,
	ModifiedTimestamp = GETUTCDATE(),
	--There is a unique constraint on AccountId/code so lets update the code to something unique so that users can delete a plan and recreate
	--it with the same code if they want a 'do-over' without having to wait for the hard delete. Code is 255 chars. the uniqueIdentifier is 36 chars
	--so if the code is short enough that adding 36 characters won't make it too long, let's add the guid.
	[Code] = CASE 
		WHEN LEN([Code]) <= 219 
		THEN CONVERT(NVARCHAR, ( CONCAT([Code], CONVERT(NVARCHAR(36),(NEWID())))))
		ELSE [Code] 
	END
WHERE [Id] = @Id

UPDATE [pp]
	SET [pp].StatusId = 4, --deleted
	[pp].ModifiedTimestamp = GETUTCDATE()
FROM PlanProduct pp
INNER JOIN [PlanRevision] pr ON pr.Id = pp.PlanRevisionId
INNER JOIN [Plan] p on p.Id = pr.PlanId
WHERE p.Id = @Id

SET NOCOUNT OFF

GO

