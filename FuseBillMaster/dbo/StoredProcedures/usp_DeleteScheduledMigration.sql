CREATE PROC [dbo].[usp_DeleteScheduledMigration]
	@Id bigint
AS
SET NOCOUNT ON

UPDATE 
	di
SET 
	di.[DraftInvoiceStatusId] = 4
FROM 
	[dbo].[DraftInvoice] AS di
	Inner JOIN [dbo].[DraftCharge] as dc on di.id = dc.DraftInvoiceId
	INNER JOIN [dbo].[DraftSubscriptionProductCharge] AS dspc ON dspc.id = dc.id
WHERE
	dspc.ScheduledMigrationId = @id


Update
	dspc
Set
	dspc.ScheduledMigrationId = null
From
	[dbo].[DraftSubscriptionProductCharge] as dspc
Where
	dspc.ScheduledMigrationId = @id


DELETE FROM [dbo].[ScheduledMigration] where id = @Id


SET NOCOUNT OFF

GO

