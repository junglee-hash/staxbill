
CREATE PROCEDURE [dbo].[usp_UpdateEntitiesWithSalesforceIds]
 @EntityTypeId int,
 @accountId bigint,
 @FusebillIds nvarchar(max),
 @SalesforceIds nvarchar(max)

AS 
		

	SELECT * INTO #tmp_SalesforceIds FROM dbo.Split(@SalesforceIds, '|')	
	SELECT * INTO #tmp_FusebillIds FROM dbo.Split(@FusebillIds, '|')

				IF(@EntityTypeId = '3') 
				Update C
				SET C.SalesforceId = sfs.Data
				FROM Customer C INNER JOIN 
				#tmp_FusebillIds fbs ON CONVERT(decimal,fbs.Data) = C.Id INNER JOIN
				#tmp_SalesforceIds sfs ON fbs.Id = sfs.Id

				IF(@EntityTypeId = '7')
				Update S
				SET S.SalesforceId = sfs.Data
				FROM Subscription S INNER JOIN 
				#tmp_FusebillIds fbs ON CONVERT(decimal,fbs.Data) = S.Id INNER JOIN
				#tmp_SalesforceIds sfs ON fbs.Id = sfs.Id
				
				IF(@EntityTypeId = '14') 
				Update SP
				SET SP.SalesforceId = sfs.Data
				FROM SubscriptionProduct SP INNER JOIN 
				#tmp_FusebillIds fbs ON CONVERT(decimal,fbs.Data) = SP.Id INNER JOIN
				#tmp_SalesforceIds sfs ON fbs.Id = sfs.Id

				IF(@EntityTypeId = '11') 
				Update INV
				SET INV.SalesforceId = sfs.Data
				FROM Invoice INV INNER JOIN 
				#tmp_FusebillIds fbs ON CONVERT(decimal,fbs.Data) = INV.Id INNER JOIN
				#tmp_SalesforceIds sfs ON fbs.Id = sfs.Id


SELECT 1

GO

