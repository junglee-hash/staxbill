
CREATE PROC [dbo].[usp_InsertTaxRuleAuditTransitions]

	@AccountId bigint,
	@UTCDate datetime

AS
SET NOCOUNT ON

--Get all active tax rules that should be audit logged
declare @taxRuleActiveAudit table
(
	Id bigint not null,
	[AccountId] [bigint] NOT NULL,
	[Percentage] [decimal](10, 8) NOT NULL,
	[Name] [nvarchar](60) NOT NULL,
	[Description] [nvarchar](250) NOT NULL,
	[CountryId] [bigint] NOT NULL,
	[StateId] [bigint] NULL,
	[RegistrationCode] [nvarchar](100) NULL,
	[CreatedTimestamp] [datetime] NOT NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[QuickBooksTaxCodeId] [bigint] NULL,
	[QuickBooksTaxRateId] [bigint] NULL,
	[TaxCode] [nvarchar](1000) NOT NULL,
	[IsRetired] [bit] NOT NULL,
	[AuditStatusId] [int] NOT NULL
)
INSERT INTO @taxRuleActiveAudit (
	[Id],
	[AccountId],
	[Percentage] ,
	[Name],
	[Description],
	[CountryId] ,
	[StateId],
	[RegistrationCode] ,
	[CreatedTimestamp] ,
	[StartDate] ,
	[EndDate] ,
	[QuickBooksTaxCodeId] ,
	[QuickBooksTaxRateId],
	[TaxCode] ,
	[IsRetired],
	[AuditStatusId] 
)
SELECT 
	[Id],
	[AccountId],
	[Percentage] ,
	[Name],
	[Description],
	[CountryId] ,
	[StateId],
	[RegistrationCode] ,
	[CreatedTimestamp] ,
	[StartDate] ,
	[EndDate] ,
	[QuickBooksTaxCodeId] ,
	[QuickBooksTaxRateId],
	[TaxCode] ,
	[IsRetired],
	[AuditStatusId] 
FROM 
	[dbo].[TaxRule] 
where 
		AccountId = @AccountId
		and AuditStatusId = 1
		and StartDate <= @UTCDate
		and StartDate is not null

--Insert entries for the audit logs
Insert into [dbo].[AuditTrail]
(
		AccountId,
		CustomerId,
		CreatedTimestamp,
		LogExpiryTimestamp,
		CategoryId,
		SourceId,
		CustomSource,
		EntityId,
		EntityValue,
		ActionId,
		ResultId,
		UserId,
		Details
)
Select 
	@AccountId as AccountId,
	null as CustomerId,
	StartDate as CreatedTimestamp,
	null as LogExpiryTimestamp,
	6 as CategoryId,
	3 as SourceId,
	null as CustomSource,
	36 as EntityId,
	TaxCode as EntityValue,
	14 as ActionId,
	1 as ResultId,
	null as UserId,
	null as Details
from 
	@taxRuleActiveAudit

--update tax rules so that they reflect the current audit status
--update 
--	[dbo].[TaxRule] 
--set 
--	[AuditStatusId] = 2 
--where 
--	AccountId = @AccountId
--	and AuditStatusId = 1
--	and StartDate <= @UTCDate
--	and StartDate is not null
UPDATE [dbo].[TaxRule] 
SET [AuditStatusId] = 2 
FROM [dbo].[TaxRule]  tr
INNER JOIN @taxRuleActiveAudit traa on traa.Id = tr.Id

--Get all expired tax rules that should be audit logged
declare @taxRuleExpiredAudit table
(
	Id bigint not null,
	[AccountId] [bigint] NOT NULL,
	[Percentage] [decimal](10, 8) NOT NULL,
	[Name] [nvarchar](60) NOT NULL,
	[Description] [nvarchar](250) NOT NULL,
	[CountryId] [bigint] NOT NULL,
	[StateId] [bigint] NULL,
	[RegistrationCode] [nvarchar](100) NULL,
	[CreatedTimestamp] [datetime] NOT NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[QuickBooksTaxCodeId] [bigint] NULL,
	[QuickBooksTaxRateId] [bigint] NULL,
	[TaxCode] [nvarchar](1000) NOT NULL,
	[IsRetired] [bit] NOT NULL,
	[AuditStatusId] [int] NOT NULL
)
INSERT INTO @taxRuleExpiredAudit (
	[Id],	
	[AccountId],
	[Percentage] ,
	[Name],
	[Description],
	[CountryId] ,
	[StateId],
	[RegistrationCode] ,
	[CreatedTimestamp] ,
	[StartDate] ,
	[EndDate] ,
	[QuickBooksTaxCodeId] ,
	[QuickBooksTaxRateId],
	[TaxCode] ,
	[IsRetired],
	[AuditStatusId] 
)
SELECT 
	[Id],
	[AccountId],
	[Percentage] ,
	[Name],
	[Description],
	[CountryId] ,
	[StateId],
	[RegistrationCode] ,
	[CreatedTimestamp] ,
	[StartDate] ,
	[EndDate] ,
	[QuickBooksTaxCodeId] ,
	[QuickBooksTaxRateId],
	[TaxCode] ,
	[IsRetired],
	[AuditStatusId] 
FROM 
	[dbo].[TaxRule] 
where 
		AccountId = @AccountId
		and AuditStatusId = 2
		and EndDate <= @UTCDate
		and EndDate is not null
		and IsRetired = 0

--Insert audit log entries
Insert into [dbo].[AuditTrail]
(
		AccountId,
		CustomerId,
		CreatedTimestamp,
		LogExpiryTimestamp,
		CategoryId,
		SourceId,
		CustomSource,
		EntityId,
		EntityValue,
		ActionId,
		ResultId,
		UserId,
		Details
)
Select 
	@AccountId as AccountId,
	null as CustomerId,
	EndDate as CreatedTimestamp,
	null as LogExpiryTimestamp,
	6 as CategoryId,
	3 as SourceId,
	null as CustomSource,
	36 as EntityId,
	TaxCode as EntityValue,
	12 as ActionId,
	1 as ResultId,
	null as UserId,
	null as Details
from 
	@taxRuleExpiredAudit

--update tax rules so that they reflect the current audit status
--update 
--	[dbo].[TaxRule] 
--set 
--	[AuditStatusId] = 3
--where 
--	AccountId = @AccountId
--	and AuditStatusId = 2
--	and EndDate <= @UTCDate
--	and EndDate is not null
--	and IsRetired = 0

UPDATE [dbo].[TaxRule] 
SET [AuditStatusId] = 3
FROM [dbo].[TaxRule]  tr
INNER JOIN @taxRuleExpiredAudit trea on trea.Id = tr.Id

SET NOCOUNT OFF

GO

