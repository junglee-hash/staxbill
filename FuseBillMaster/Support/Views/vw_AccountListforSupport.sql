
CREATE VIEW [Support].[vw_AccountListforSupport]
AS
SELECT         Id AS AccountId, ContactEmail, CompanyName, FusebillTest, Signed, Live
FROM            dbo.Account WITH (nolock)

GO

