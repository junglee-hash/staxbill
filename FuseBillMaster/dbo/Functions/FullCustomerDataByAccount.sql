
CREATE FUNCTION [dbo].[FullCustomerDataByAccount]  
(   
 @AccountId AS BIGINT,  
 @CurrencyId AS BIGINT,  
 @UTCEndDateTime AS DATETIME  
)  
RETURNS TABLE   
AS  
RETURN   
(  
 WITH EffectiveAccountingStatus AS  
(  
SELECT   
 CustomerId  
 , id
 ,StatusId
FROM (SELECT    
  CustomerId  
  , j.Id AS Id,  
  MAX(SequenceNumber) OVER(PARTITION BY CustomerId) AS maxSequence,  
  SequenceNumber,
  j.StatusId
 FROM   
  CustomerAccountStatusJournal j  
  INNER JOIN Customer c  
  ON j.CustomerId = c.Id  
 WHERE  
  c.AccountId = @AccountId   
  AND j.EffectiveTimestamp < @UTCEndDateTime   
  AND ((c.CurrencyId = @CurrencyId) OR (@CurrencyId IS NULL))   
 ) a  
WHERE maxSequence = SequenceNumber  
  
)  
,EffectiveCustomerStatus AS  
(  
SELECT   
 CustomerId  
 , id  
FROM (SELECT    
  CustomerId  
  , j.Id AS Id,  
  MAX(SequenceNumber) OVER(PARTITION BY CustomerId) AS maxSequence,  
  SequenceNumber  
 FROM   
  CustomerStatusJournal j  
  INNER JOIN Customer c  
  ON j.CustomerId = c.Id  
 WHERE  
  c.AccountId = @AccountId   
  AND j.EffectiveTimestamp < @UTCEndDateTime   
  AND ((c.CurrencyId = @CurrencyId) OR (@CurrencyId IS NULL))   
 ) a  
WHERE maxSequence = SequenceNumber  
)  

 SELECT  
  c.Id AS [Fusebill ID]  
 ,ISNULL(c.Reference,'') AS [Customer ID]  
 ,ISNULL(c.FirstName,'') AS  [Customer First Name]  
 ,ISNULL(c.LastName,'') AS [Customer Last Name]  
 ,ISNULL(c.CompanyName,'') AS [Customer Company Name]  
 ,c.ParentId AS [Customer Parent ID] -- standard stops here  
 ,c.QuickBooksId AS [QuickBooks ID]  
 ,c.NetsuiteId as [Netsuite Id]   
 ,c.SalesforceId as [Salesforce Id]  
 ,ci.[Hubspot Contact Id]  
 ,ci.[Hubspot Company Id]   
 ,ISNULL(c.PrimaryPhone,'') AS [Phone1]  
 ,ISNULL(c.SecondaryPhone,'') AS [Phone2]  
 ,ISNULL(c.PrimaryEmail,'') AS [Email1]  
 ,ISNULL(c.SecondaryEmail,'') AS [Email2]  
 ,ISNULL(a.Line1,'') AS [Address Line1]  
 ,ISNULL(a.Line2,'') AS [Address Line2]  
 ,ISNULL(co.Name,'') AS [Country]  
 ,ISNULL(st.Name,'') AS [State]  
 ,ISNULL(a.County,'') AS [County]  
 ,ISNULL(a.City,'') AS [City]  
 ,ISNULL(a.PostalZip,'') AS [Zip]  
 ,ISNULL(cr.Reference1,'') AS [Ref1]  
 ,ISNULL(cr.Reference2,'') AS [Ref2]  
 ,ISNULL(cr.Reference3,'') AS [Ref3]  
 ,ISNULL(stc1.Code,'') AS [SalesTrackingCode1Code]  
 ,ISNULL(stc1.Name,'') AS [SalesTrackingCode1Name]  
 ,ISNULL(stc2.Code,'') AS [SalesTrackingCode2Code]  
 ,ISNULL(stc2.Name,'') AS [SalesTrackingCode2Name]  
 ,ISNULL(stc3.Code,'') AS [SalesTrackingCode3Code]  
 ,ISNULL(stc3.Name,'') AS [SalesTrackingCode3Name]  
 ,ISNULL(stc4.Code,'') AS [SalesTrackingCode4Code]  
 ,ISNULL(stc4.Name,'') AS [SalesTrackingCode4Name]  
 ,ISNULL(stc5.Code,'') AS [SalesTrackingCode5Code]  
 ,ISNULL(stc5.Name,'') AS [SalesTrackingCode5Name]  
 ,ISNULL(cas.Name,'') AS [Accounting Status (applicable at effective date of report)]  
 ,ISNULL(cs.Name,'') AS [Status (applicable at effective date of report)]  
    ,ISNULL(clh.Name,'') AS [Collection Likelihood]  
 FROM Customer c  
 LEFT JOIN CustomerAddressPreference cap ON c.Id = cap.Id  
 LEFT JOIN Address a ON cap.Id = a.CustomerAddressPreferenceId AND a.AddressTypeId = 1  
 LEFT JOIN lookup.Country co ON a.CountryId = co.Id  
 LEFT JOIN lookup.State st ON a.StateId = st.Id  
 LEFT JOIN CustomerReference cr ON c.Id = cr.Id   
 LEFT JOIN SalesTrackingCode stc1 ON cr.SalesTrackingCode1Id = stc1.Id  
 LEFT JOIN SalesTrackingCode stc2 ON cr.SalesTrackingCode2Id = stc2.Id  
 LEFT JOIN SalesTrackingCode stc3 ON cr.SalesTrackingCode3Id = stc3.Id  
 LEFT JOIN SalesTrackingCode stc4 ON cr.SalesTrackingCode4Id = stc4.Id  
 LEFT JOIN SalesTrackingCode stc5 ON cr.SalesTrackingCode5Id = stc5.Id  
 LEFT JOIN lookup.CollectionLikelihood clh ON clh.Id = c.CollectionLikelihood  
 LEFT OUTER JOIN (  
  SELECT CustomerId  
  ,MAX(CASE WHEN CustomerIntegrationTypeId = 1 THEN IntegrationId END) AS [Hubspot Contact Id]  
  ,MAX(CASE WHEN CustomerIntegrationTypeId = 2 THEN IntegrationId END) AS [Hubspot Company Id]  
  FROM CustomerIntegration ci  
  GROUP BY CustomerId  
  ) ci ON c.Id = ci.CustomerId  
 LEFT JOIN EffectiveAccountingStatus eas ON c.Id = eas.CustomerId   
 LEFT JOIN lookup.CustomerAccountStatus cas ON eas.StatusId = cas.Id  
 INNER JOIN EffectiveCustomerStatus ecs ON c.Id = ecs.CustomerId   
 INNER JOIN CustomerStatusJournal csj ON ecs.Id = csj.Id  
 INNER JOIN lookup.CustomerStatus cs ON csj.StatusId = cs.Id  
 WHERE c.AccountId = @AccountId  
)

GO

