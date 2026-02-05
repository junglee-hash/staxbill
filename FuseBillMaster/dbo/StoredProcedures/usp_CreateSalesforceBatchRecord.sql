CREATE procedure [dbo].[usp_CreateSalesforceBatchRecord]
     @AccountId bigint
    ,@EntityTypeId int
    ,@SalesforceBatchId bigint
AS

set transaction isolation level snapshot

BEGIN TRAN

declare @recordStatus as int
set @recordStatus = (select id from Lookup.IntegrationSynchBatchRecordStatus where name = 'Incompleted')

IF @EntityTypeId = 3 
INSERT INTO dbo.IntegrationSynchBatchRecord (IntegrationSynchBatchId, EntityTypeId, EntityId, ExternalId, StatusId)  
SELECT @SalesforceBatchId, @EntityTypeId, Id, SalesforceId, 1 FROM dbo.Customer cs
WHERE cs.AccountId = @AccountId ORDER BY cs.Id


IF @EntityTypeId = 7
INSERT INTO dbo.IntegrationSynchBatchRecord (IntegrationSynchBatchId, EntityTypeId, EntityId, ExternalId, StatusId)  
SELECT @SalesforceBatchId, @EntityTypeId, Id, SalesforceId, 1 FROM dbo.Subscription sub
WHERE sub.CustomerId in (Select Id from dbo.Customer cs where cs.AccountId = @AccountId) ORDER BY sub.Id

IF @EntityTypeId = 11
INSERT INTO dbo.IntegrationSynchBatchRecord (IntegrationSynchBatchId, EntityTypeId, EntityId, ExternalId, StatusId)  
SELECT @SalesforceBatchId, @EntityTypeId, Id, SalesforceId, 1 FROM dbo.Invoice inv
WHERE inv.AccountId = @AccountId ORDER BY inv.Id

IF @EntityTypeId = 14
INSERT INTO dbo.IntegrationSynchBatchRecord (IntegrationSynchBatchId, EntityTypeId, EntityId, ExternalId, StatusId)  
SELECT @SalesforceBatchId, @EntityTypeId, Id, SalesforceId, 1 FROM dbo.SubscriptionProduct subProd
WHERE subProd.SubscriptionId in (SELECT ID FROM dbo.Subscription sub
WHERE sub.CustomerId in (Select Id from dbo.Customer cs where cs.AccountId = @AccountId)) ORDER BY subProd.Id

COMMIT TRAN

SELECT COUNT(*) from dbo.IntegrationSynchBatchRecord
WHERE IntegrationSynchBatchId = @SalesforceBatchId AND EntityTypeId = @EntityTypeId

GO

